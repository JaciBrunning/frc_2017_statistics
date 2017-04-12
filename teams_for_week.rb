# ruby teams_for_week <week>

require 'sqlite3'

@weeks = File.read("weeks.csv").split(/\n/).map { |x| x.split(",") }
@weeks = Hash[@weeks.map{ |x| x[0] }.zip @weeks.map { |x| { :start => x[1], :end => x[2]}}]

TARGET = ARGV[0].to_s
DB_FILE = "frc2017.db"

@t = @weeks[TARGET]

@db = SQLite3::Database.new DB_FILE

results = @db.execute File.read("analysis/teams_for_week.sql").gsub(/START_DATE/, "2017-" + @t[:start]).gsub(/END_DATE/, "2017-" + @t[:end])
printf "%-10s | %-10s | %-10s\n", "Team", "Event", "Event Name"
results.each { |res| printf "%-10d | %-10s | %-10s\n", *res }