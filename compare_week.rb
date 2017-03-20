# ruby compare_week.rb <newer_week> <older_week>
# ruby compare_week.rb <start_new_week>-<end_new_week> <start_old_week>-<end_old_week>
# ruby compare_week.rb FILE <file_new> <file_old>

WEEK = ARGV[0].to_s
COMPARE = ARGV[1].to_s

@new_file = nil
@old_file = nil
week = nil
compare = nil
if WEEK.downcase == "file"
    @new_file = ARGV[1].to_s
    @old_file = ARGV[2].to_s

    week = File.read(@new_file)
    compare = File.read(@old_file)
else
    week_scan = WEEK.scan(/(\d+)-?(\d+)?/).flatten
    week_scan[1] = week_scan[0] if week_scan[1].nil?

    cmp_scan = COMPARE.scan(/(\d+)-?(\d+)?/).flatten
    cmp_scan[1] = cmp_scan[0] if cmp_scan[1].nil?

    week = `ruby analyse_week.rb #{week_scan[0]} #{week_scan[1]}`
    compare = `ruby analyse_week.rb #{cmp_scan[0]} #{cmp_scan[1]}`
end

def map_values arr
    lines = []
    arr.split(/\n/).map do |line|
        totals_avgs = line.scan(/([0-9.]+)\s+\(\s*([0-9.]+)\)/).flatten
        misc = line.scan(/([0-9.]+)\s+\(\s*([0-9.]+)%\)/).flatten
        percs = line.scan(/([0-9.]+)%/).flatten
        percs = [] if misc.count > 1
        lines << [totals_avgs, misc, percs]
    end
    lines
end

week_values = map_values week
cmp_values = map_values compare

week.split(/\n/).zip(week_values.zip(cmp_values)).map do |line|
    text = line[0]
    next if text.nil? || text.empty?
    week_val = line[1][0].reject { |x| x.empty? }[0]
    cmp_val = line[1][1].nil? ? nil : line[1][1].reject { |x| x.empty? }[0]

    delta = nil
    form_text = ""
    unless week_val.nil? || cmp_val.nil?
        delta = week_val.zip(cmp_val).map { |x| x[0].to_f - x[1].to_f }
        delta_texts = delta.map { |x| x=x.round(1); x == 0 ? ["=", 0] : x < 0 ? ["-", -x] : ["+", x] }
        if delta_texts.count == 1
            form_text = sprintf("%1s %-8.1f", delta_texts[0][0], delta_texts[0][1])
        else
            form_text = sprintf("%1s %-7.0f (%1s %4.1f)", delta_texts[0][0], delta_texts[0][1], delta_texts[1][0], delta_texts[1][1])
        end
    end
    puts "#{text}    #{delta.nil? ? "" : form_text}"
end