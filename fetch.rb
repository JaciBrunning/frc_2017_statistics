require 'open-uri'
require 'openssl'
require 'json'
require 'sqlite3'
require 'fileutils'
require 'digest'

DB_FILE = "frc2017.db"
CACHE_FOLDER = "_tbacache"

SKIP_DISTRICT = ARGV.include? "--skip-districts"
SKIP_EVENT = ARGV.include? "--skip-events"
SKIP_TEAM = ARGV.include? "--skip-teams"
SKIP_ALLIANCE = ARGV.include? "--skip-alliances"
SKIP_MATCH = ARGV.include? "--skip-matches"
SKIP_AWARD = ARGV.include? "--skip-awards"
SKIP_STATS = ARGV.include? "--skip-stats"
SKIP_RANK = ARGV.include? "--skip-ranks"

PURGE_DB = ARGV.include? "--purge-db"       # Force a new DB to be made
PURGE_CACHE = ARGV.include? "--purge-cache" # Force all TBA Caches to be remade

# If you dirty the cache, you will need to remake the db. 
# Use ruby fetch.rb --purge-db --dirty-<something> to achieve this.
CACHE_DIRTY_EVENTS = ARGV.include? "--dirty-events" # Force TBA event cache (event list) to be remade
CACHE_DIRTY_TEAMS = ARGV.include? "--dirty-teams"   # Force TBA team cache (team listings for events) to be remade
CACHE_DIRTY_DISTRICTS = ARGV.include? "--dirty-districts"    # Force TBA district cache (district list) to be remade
CACHE_DIRTY_DISTRICT_RANKS = ARGV.include? "--dirty-district-ranks" # Force TBA district rank/points to be remade
CACHE_DIRTY_STATS = ARGV.include? "--dirty-stats"   # Force TBA stats cache (opr, dpr, etc) to be remade
CACHE_DIRTY_RANKS = ARGV.include? "--dirty-ranks"   # Force TBA ranks cache (event rankings) to be remade
CACHE_DIRTY_AWARDS = ARGV.include? "--dirty-award"  # Force TBA awards cache (award recipients) to be remade
# Alliances are dirtied by events.
CACHE_DIRTY_MATCHES = ARGV.include? "--dirty-matches" # Force TBA matches cache to be remade


def load_model model_name
    File.read "models/#{model_name}.sql"
end

def load_and_run model_name
    load_model(model_name).split(";").each do |a|
        @db.execute a
    end
end

def query model_name, datum
    @db.execute load_model(model_name), datum
end

def queryt model_name, datum
    begin
        query model_name, datum
    rescue
    end
end

def queryv model_name, datum
    begin
        query model_name, datum
        puts "DONE!"
    rescue => e
        puts "SKIP!"
    end
end

MATCH_V = {
    "qm" => "Qualifications",
    "ef" => "Octofinals",
    "qf" => "Quarterfinals",
    "sf" => "Semifinals",
    "f" => "Finals"
}

def match_verbose m
    if (m["comp_level"] == "qm") || (m["comp_level"] == "f")
        return "#{MATCH_V[m["comp_level"]]} #{m["match_number"]}"
    else
        return "#{MATCH_V[m["comp_level"]]} #{m["set_number"]} Match #{m["match_number"]}"
    end
end

def tba_call api_ref, force=false
    # Call hash logic
    hashfile = "#{CACHE_FOLDER}/#{Digest::MD5.hexdigest(api_ref)}"
    File.delete(hashfile) if (File.exists?(hashfile) && (PURGE_CACHE || force))
    if File.exists?(hashfile)
        JSON.parse(File.read(hashfile))
    else
        response = open("https://www.thebluealliance.com/api/v2/#{api_ref}?X-TBA-App-Id=jaci:frc_db:2017.0.0", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
        File.write(hashfile, response)
        JSON.parse response
    end
end

FileUtils.rm_rf(CACHE_FOLDER) if File.exists?(CACHE_FOLDER) && PURGE_CACHE
FileUtils.mkdir_p(CACHE_FOLDER)
File.delete(DB_FILE) if File.exists?(DB_FILE) && PURGE_DB
newfile = !File.exists?(DB_FILE)
@db = SQLite3::Database.new DB_FILE

if newfile
    load_and_run("create/districts")
    load_and_run("create/teams")
    load_and_run("create/events")
    load_and_run("create/alliances")
    load_and_run("create/matches")
    load_and_run("create/awards")
    load_and_run("create/stats")
    load_and_run("create/rankings")
end

events = tba_call "events/2017", CACHE_DIRTY_EVENTS
events.each { |x| x["happened"] = (DateTime.parse(x["end_date"]) < DateTime.now) }  # For now
unless SKIP_EVENT
    puts "Insering Events..."
    @db.transaction
    events.each do |e|
        print "  Event: #{e["name"]}..."
        queryv "insert/events", [
            e["key"], e["event_code"],e["name"], e["short_name"], e["official"] ? 1 : 0,
            e["event_type_string"],
            e["location"], 
            e["start_date"],
            e["end_date"],
            e["event_district_string"]
        ]
    end
    @db.commit
end

unless SKIP_TEAM
    puts
    puts "Inserting Teams..."
    events.each do |event|
        puts "  Teams for event: #{event["name"]}..."
        teams = tba_call "event/#{event["key"]}/teams", CACHE_DIRTY_TEAMS
        @db.transaction
        teams.each do |t|
            print "    Team #{t["team_number"]}..."
            queryv "insert/teams", [
                t["team_number"], t["key"], t["name"], t["nickname"],
                t["location"], t["region"], t["country_name"], t["rookie_year"]
            ]
        end
        @db.commit
        
        @db.transaction
        puts "  Team link for event: #{event["name"]}..." 
        teams.each do |t|
            print "    Team #{t["team_number"]}..."
            queryv "insert/event_teams", [
                t["team_number"], event["key"]
            ]
        end
        @db.commit
    end
end

unless SKIP_DISTRICT
    puts
    puts "Fetching Districts..."
    districts = tba_call "districts/2017", CACHE_DIRTY_DISTRICTS
    puts "Inserting Districts..."
    
    districts.each do |district|
        @db.transaction
        print "  District: #{district["name"]}..."
        queryv "insert/districts/district", [ district["key"], district["name"] ]
        
        district_teams = tba_call "district/#{district["key"]}/2017/teams", CACHE_DIRTY_DISTRICTS
        district_teams.each do |team|
            print "    Team #{team["team_number"]}..."
            queryv "insert/districts/team", [
                team["team_number"], district["key"]
            ]
        end
        @db.commit
    end
    
    puts "Inserting District Rankings"
    districts.each do |district|
        @db.transaction
        district_rankings = tba_call "district/#{district["key"]}/2017/rankings", CACHE_DIRTY_DISTRICT_RANKS
        district_rankings.each do |rank|
            print "    Rank for Team: #{rank["team_key"]}..."
            queryv "insert/districts/rankings", [
                rank["team_key"], district["key"],
                rank["rank"], rank["point_total"], rank["rookie_bonus"]
            ]
            
            rank["event_points"].each do |event, p|
                print "      Rank at Event: #{event}..."
                queryv "insert/districts/event_points", [
                    rank["team_key"], event, district["key"],
                    p["alliance_points"], p["award_points"],
                    p["qual_points"], p["elim_points"], p["total"]
                ]
            end
        end
        @db.commit
    end
end

unless SKIP_STATS
    puts
    puts "Insering Stats..."
    events.select { |x| x["happened"] }.each do |event|
        puts "  Stats for event: #{event["name"]}"
        stats = tba_call "event/#{event["key"]}/stats", CACHE_DIRTY_STATS
        teams = {}
        
        @db.transaction
        unless stats["oprs"].nil?
            stats["oprs"].each do |t, stat|
                teams[t] = { "opr" => stat, "dpr" => 0, "ccwm" => 0 }
            end
            stats["dprs"].each do |t, stat|
                teams[t]["dpr"] = stat
            end
            stats["ccwms"].each do |t, stat|
                teams[t]["ccwm"] = stat
            end
            
            teams.each do |t, s|
                print "    Team #{t}..."
                queryv "insert/stats", [
                    t, event["key"], s["opr"], s["dpr"], s["ccwm"]
                ]
            end
        end
        @db.commit
    end
end

unless SKIP_RANK
    puts
    puts "Inserting Rankings..."
    events.select { |x| x["happened"] }.each do |event|
        puts "  Rankings for event: #{event["name"]}"
        ranks = tba_call "event/#{event["key"]}/rankings", CACHE_DIRTY_RANKS
        
        unless ranks.length == 0
            rank_datum = ranks.shift.map { |x| x.downcase }
            
            @db.transaction
            ranks.each do |x|
                x.map! { |x| unless x.to_s.include?("-"); x.to_f; else; x; end }
                result = Hash[rank_datum.zip(x)]
                wlt = result["record (w-l-t)"].split("-").map { |x| x.to_i }
                print "    Team: #{result["team"].to_i}..."
                
                queryv "insert/rankings", [
                    result["team"].to_i, event["key"],
                    result["rank"], result["ranking score"],
                    result["match points"], result["auto"],
                    result["rotor"], result["touchpad"], result["pressure"],
                    wlt[0], wlt[1], wlt[2], result["played"].to_i
                ]
            end
            @db.commit
        end
    end
end

unless SKIP_AWARD
    puts
    puts "Inserting Awards..."
    events.select { |x| x["happened"] }.each do |event|
        puts "  Awards for event: #{event["name"]}"
        awards = tba_call "event/#{event["key"]}/awards", CACHE_DIRTY_AWARDS
        @db.transaction
        awards.each do |a|
            print "      #{a["name"]}..."
            
            queryv "insert/awards/award", [
                a["award_type"], a["name"]
            ]
            
            unless a["recipient_list"].nil?
                a["recipient_list"].each do |r|
                    query "insert/awards/recipient", [
                        a["event_key"], r["team_number"], r["awardee"], a["award_type"]
                    ]
                end
            end
        end
        @db.commit
    end
end

unless SKIP_ALLIANCE
    puts
    puts "Inserting Alliances..."
    @db.transaction
    events.select { |x| x["happened"] }.each do |event|
        puts "  Alliances for event: #{event["name"]}..."
        event["alliances"].each_with_index do |a, i|
            queryt "insert/alliances/alliance", [
                i+1, event["event_code"]
            ]
            
            a["picks"].each_with_index do |p, j|
                queryt "insert/alliances/pick", [
                    i+1, event["event_code"], j, p
                ]
            end
            
        end
    end
    @db.commit
end

unless SKIP_MATCH
    puts
    puts "Inserting Matches..."
    events.select { |x| x["happened"] }.each do |event|
        puts "  Matches for event: #{event["name"]}..."
        matches = tba_call "event/#{event["key"]}/matches", CACHE_DIRTY_MATCHES
        
        @db.transaction
        matches.each do |m|
            puts "    Insert #{match_verbose(m)}..."
            if m["score_breakdown"] != nil
                queryt "insert/matches/match", [
                    m["key"], event["event_code"],
                    m["comp_level"], m["match_number"],
                    m["set_number"]
                ]
            end
        end
        @db.commit
        
        @db.transaction
        matches.each do |m|
            puts "    Populate #{match_verbose(m)}..."
            if m["score_breakdown"] != nil
                ["red", "blue"].each do |all|
                    bd = m["score_breakdown"][all]
                    alliances = m["alliances"][all]
                    station = 1
                    alliances["teams"].each do |t|
                        queryt "insert/matches/match_teams", [
                            m["key"], all, station, t
                        ]
                        station += 1
                    end
                
                    queryt "insert/matches/match_scores", [
                        m["key"], all,
                        
                        bd["teleopPoints"], bd["teleopRotorPoints"], 
                        bd["teleopFuelHigh"], bd["teleopFuelHigh"]/3,
                        bd["teleopFuelLow"], bd["teleopFuelLow"]/9,
                        bd["teleopFuelPoints"], bd["teleopTakeoffPoints"],
                        
                        bd["autoPoints"], bd["autoRotorPoints"],
                        bd["autoFuelHigh"], bd["autoFuelHigh"],
                        bd["autoFuelLow"], bd["autoFuelLow"]/3,
                        bd["autoFuelPoints"], bd["autoMobilityPoints"],

                        bd["rotorBonusPoints"], bd["rotorRankingPointAchieved"] ? 1 : 0,
                        bd["kPaBonusPoints"], bd["kPaRankingPointAchieved"] ? 1 : 0,

                        bd["foulPoints"], bd["foulCount"], bd["techFoulCount"],

                        bd["totalPoints"], bd["adjustPoints"]
                    ]

                    touchpads = ["Near", "Middle", "Far"]
                    (1..4).each do |num|
                        queryt "insert/matches/match_rotors", [
                            m["key"], all,
                            num, bd["rotor#{num}Engaged"] ? 1 : 0, bd["rotor#{num}Auto"] ? 1 : 0
                        ]
                        unless num == 4
                            pad = "touchpad#{touchpads[num-1]}"
                            queryt "insert/matches/match_mobility", [
                                m["key"], all, alliances["teams"][num-1],
                                bd["robot#{num}Auto"] == "Mobility" ? 1 : 0
                            ]
                            queryt "insert/matches/match_touchpads", [
                                m["key"], all, num, bd[pad] == "ReadyForTakeoff" ? 1 : 0
                            ]
                        end
                    end
                end
            end
        end
        @db.commit
    end
end