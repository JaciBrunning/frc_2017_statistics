# ruby analyse_week.rb <week>
# ruby analyse_week.rb <week_start> <week_end>

@weeks = File.read("weeks.csv").split(/\n/).map { |x| x.split(",") }
@weeks = Hash[@weeks.map{ |x| x[0] }.zip @weeks.map { |x| { :start => x[1], :end => x[2]}}]

TARGET = ARGV[0].to_s
TARGET_END = ARGV[1].nil? ? nil : ARGV[1].to_s
t = @weeks[TARGET]
t2 = TARGET_END.nil? ? t : @weeks[TARGET_END]
cmd = "ruby analyse.rb \"SQL[INNER JOIN events ON matches.event == events.id] WHERE julianday(events.start_date) > julianday(\\\"2017-#{t[:start]}\\\") WHERE julianday(events.end_date) < julianday(\\\"2017-#{t2[:end]}\\\")\""
puts `#{cmd}`