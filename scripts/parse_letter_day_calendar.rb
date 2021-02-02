require "set"

ht = {}

def good_date?(s)
  s.match /\A2021-[01][0-9]-[0123][0-9]\Z/
end

def good_letter_day?(s)
  good_letterdays = Set.new %w[A B C D E F G]

  good_letterdays.include? s
end

def good_previous_letter_day?(current, previous)
  correct_previous = {
    "A" => "G",
    "B" => "A",
    "C" => "B",
    "D" => "C",
    "E" => "D",
    "F" => "E",
    "G" => "F",
  }

  correct_previous[current] == previous
end

previous_letter_day = nil

File.open(ARGV.first).each_line.with_index do |line, idx|
  if idx.zero?
    unless line.chomp == "Date\tLetterDay"
      abort "ERROR -- bad header: #{line.inspect}"
    end
  else
    date, letter_day = line.chomp.split "\t"

    unless good_date? date
      abort "ERROR -- bad format for: #{date}"
    end

    if ht.has_key? date
      abort "ERROR -- #{date} is repeated in #{ARGV.first}"
    end

    unless good_letter_day? letter_day
      abort "ERROR -- bad letter_day for: #{letter_day}"
    end

    unless previous_letter_day.nil? || good_previous_letter_day?(current, previous)
      abort "ERROR -- bad previous letter day for #{line.inspect}.  " \
            "Current letter_day: #{letter_day}.  Previous: #{previous_letter_day}."
    end

    ht[date] = letter_day
  end
end

ht.each_with_index do |(date, letter_day), idx|
  if idx.zero?
    puts %Q|[ ("#{date}", #{letter_day})|
  else
    puts %Q|, ("#{date}", #{letter_day})|
  end
end
puts "]"
