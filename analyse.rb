require 'sqlite3'

WHERE = ARGV.join(" ").scan(/WHERE ([^\s]*)\s*([!=><]+)\s*([^\s]*)/)
CUSTOM_SQL = ARGV.join(" ").scan(/SQL\[(.*)\]/)

DB_FILE = "frc2017.db"
@db = SQLite3::Database.new DB_FILE
@db.results_as_hash = true

# Format: <name> <suffix> [prefixes, compare]
ALL_STATS = [
    ["Match Points", "points", ["total", ["auto", "total"], ["teleop", "total"], ["foul", "total"], "adjust"]],
    ["Mobility Points", "mobility_points", [["auto", "auto"]]],
    ["Rotor Points", "rotor_points", [["auto", "auto"], ["teleop", "teleop"]]],
    ["Takeoff Points", "takeoff_points", [["teleop", "teleop"]]],
    ["Fuel High Points", "fuel_high_points", [["auto", "auto"], ["teleop", "teleop"]]],
    ["Fuel Low Points", "fuel_low_points", [["auto", "auto"], ["teleop", "teleop"]]],
    ["Foul Count", "count", ["foul", "tech_foul"]]
]

QUAL_STATS = [
    ["Bonus Rank Points", "bonus_rank_point", ["rotor", "pressure"]]
]

PLAYOFF_STATS = [
    ["Bonus Points", "bonus_points", [["rotor", "total"], ["pressure", "total"]]]
]

# Build Stat Queries
def exec_all_stat key
    query = ["SELECT sum(m.#{key}) as [total], avg(m.#{key}) as [avg] FROM match_scores AS m",
    "INNER JOIN matches ON m.match == matches.id, match_levels ON matches.match_level == match_levels.id",
    [CUSTOM_SQL],
    [WHERE.size > 0 ? "WHERE" : ""],
    WHERE.map { |x| "#{x[0]}#{x[1]}#{x[2]}" }.join(" AND ")].flatten.join(" ")
    @db.get_first_row(query)
end

def exec_qual_stat key
    query = ["SELECT sum(m.#{key}) as [total], avg(m.#{key}) as [avg] FROM match_scores AS m",
    "INNER JOIN matches ON m.match == matches.id, match_levels ON matches.match_level == match_levels.id",
    [CUSTOM_SQL],
    "WHERE match_levels.key == \"qm\"",
    [WHERE.size > 0 ? "AND" : ""],
    WHERE.map { |x| "#{x[0]}#{x[1]}#{x[2]}" }.join(" AND ")].join(" ")
    @db.get_first_row(query)
end

def exec_playoff_stat key
    query = ["SELECT sum(m.#{key}) as [total], avg(m.#{key}) as [avg] FROM match_scores AS m",
    "INNER JOIN matches ON m.match == matches.id, match_levels ON matches.match_level == match_levels.id",
    [CUSTOM_SQL],
    "WHERE match_levels.key != \"qm\"",
    [WHERE.size > 0 ? "AND" : ""],
    WHERE.map { |x| "#{x[0]}#{x[1]}#{x[2]}" }.join(" AND ")].join(" ")
    @db.get_first_row(query)
end

# Prefetch Total Scores
@totals = Hash[["total", "auto", "teleop"].map { |x| [x, exec_all_stat("#{x}_points")["total"].to_f] }]
@qual_totals = Hash[["total", "auto", "teleop"].map { |x| [x, exec_all_stat("#{x}_points")["total"].to_f] }]
@playoff_totals = Hash[["total", "auto", "teleop"].map { |x| [x, exec_all_stat("#{x}_points")["total"].to_f] }]

@totals_out = {"total": [], "auto": [], "teleop": []}

# Printing Code
def print_stat stat, totals, match_type
    human_name = stat[0]
    suffix = stat[1]
    prefixes = stat[2]

    printf "%20s:\n", human_name
    prefixes.each do |prefix|
        pre = prefix
        compare = nil
        if prefix.kind_of?(Array)
            pre = prefix[0]
            compare = prefix[1]
        end

        q = exec_all_stat("#{pre}_#{suffix}") if match_type == :all
        q = exec_qual_stat("#{pre}_#{suffix}") if match_type == :qual
        q = exec_playoff_stat("#{pre}_#{suffix}") if match_type == :playoff
        printf "%12s %13s: %6d (%6.2f)\n", "", pre, q["total"], q["avg"]
        unless compare.nil?
            @totals_out[compare.to_sym].push [human_name, pre, q["total"]/totals[compare]*100]
        end
    end
    puts 
end

# Main Code
puts "======================="
puts "      ALL MATCHES      "
puts "======================="
ALL_STATS.each { |s| print_stat s, @totals, :all }

puts "======================="
puts " QUALIFICATION MATCHES "
puts "======================="
QUAL_STATS.each { |s| print_stat s, @qual_totals, :qual }

puts "======================="
puts "    PLAYOFF MATCHES    "
puts "======================="
PLAYOFF_STATS.each { |s| print_stat s, @qual_totals, :playoff }

puts "======================="
puts "    SCORE BREAKDOWN    "
puts "======================="
@totals_out.each do |title, arr|
    printf "%20s:\n", (title.to_s.capitalize + " Points")
    arr.each do |entry|
        if entry[1] == title.to_s
            printf "%15s %15s: %8.1f%%\n", "", entry[0].sub(" Points", ""), entry[2]
        else
            printf "%4s %15s %-10s: %8.1f%%\n", "", entry[0].sub(" Points", ""), "(" + entry[1] + ")", entry[2]
        end
    end
    puts
end

puts "======================="
puts "   MISCELLANEOUS DATA  "
puts "======================="

fuel_deciders = @db.execute(File.read("analysis/fuel_decides.sql")).count
foul_deciders = @db.execute(File.read("analysis/foul_decides.sql")).count
loser_climbs = @db.execute(File.read("analysis/losers_more_climbs_than_winners.sql")).count

match_count = @db.get_first_row("SELECT count(matches.id) as [count] FROM matches")["count"]

printf "%20s: %8d (%3.1f%%)\n", "Wins due to Fuel", fuel_deciders, (fuel_deciders.to_f / match_count*100)
printf "%20s: %8d (%3.1f%%)\n", "Wins due to Fouls", foul_deciders, (foul_deciders.to_f / match_count*100)
puts
printf "%20s: %8d (%3.1f%%)\n", "L Climbs > W Climbs", loser_climbs, (loser_climbs.to_f / match_count*100)