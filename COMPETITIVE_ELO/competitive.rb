require 'sqlite3'
require 'json'

BASE_RATING = 2500
K_VALS = Proc.new { |team| team[:played] < 15 ? 300 : 250 }
STREAK_BONUS = 0.1
MARGIN_BONUS = 1

RANK = Proc.new do |r|
    rank = "<none>"
    if r < 1500
        rank = "Bronze"
    elsif r < 2000
        rank = "Silver"
    elsif r < 2500
        rank = "Gold"
    elsif r < 3000
        rank = "Platinum"
    elsif r < 3500
        rank = "Diamond"
    elsif r < 4000
        rank = "Master"
    else
        rank = "Grandmaster"
    end
    rank
end

@wlt_file = File.read("win_tie_loss.sql")

@db = SQLite3::Database.new "../frc2017.db"
@db.results_as_hash = true

@results = @db.execute(@wlt_file)

@team_elo = {}
@matches = {}

@results.each do |result|
    t = result["team"]
    m = result["match"]
    a = result["alliance"] == "blue" ? :b : :r
    na = a == :b ? :r : :b
    @team_elo[t] = { :rating => BASE_RATING, :played => 0, :streak => 0 } unless @team_elo.include? t   
   
    @matches[m] = {:r => {:teams => [], :score => 0}, :b => {:teams => [], :score => 0}} unless @matches.include? m
    @matches[m][a][:teams] << t

    if result["win"] == "t"
        @matches[m][:r][:score] = 0.5
        @matches[m][:b][:score] = 0.5
        @matches[m][:margin] = 0
    else
        @matches[m][a][:score] = (result["win"] == "w" ? 1.0 : 0.0)
        @matches[m][na][:score] = 1-(@matches[m][a][:score])
        @matches[m][:margin] = (result["team_score"] - result["opp_score"]).abs
    end
end

@matches.each do |match, m|
    red_avg = m[:r][:teams].map { |t| @team_elo[t][:rating] }.instance_eval { reduce(:+) / size.to_f }
    blu_avg = m[:b][:teams].map { |t| @team_elo[t][:rating] }.instance_eval { reduce(:+) / size.to_f }

    expected_red_score = 1/(1+10**(blu_avg - red_avg)/400)
    expected_blu_score = 1/(1+10**(red_avg - blu_avg)/400)

    red_delta = m[:r][:score] - expected_red_score
    blu_delta = m[:b][:score] - expected_blu_score

    calc = Proc.new do |team, delta, score|
        elo = @team_elo[team]
        elo[:played] += 1

        elo[:rating] += (K_VALS.call(elo) + m[:margin] * MARGIN_BONUS) * delta * (1.0 + STREAK_BONUS*elo[:streak])

        elo[:streak] += 1 if score == 1.0
        elo[:streak] = 0 unless score == 1.0
    end

    m[:r][:teams].each { |t| calc.call(t, red_delta, m[:r][:score]) }
    m[:b][:teams].each { |t| calc.call(t, blu_delta, m[:b][:score]) }
end

puts "team,rating,matches_played,rank\n"
puts @team_elo.map { |x, y| "#{x},#{y[:rating].round(0)},#{y[:played]},#{RANK.call(y[:rating])}" }.join("\n")
