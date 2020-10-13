def nice_word(line)
  vowels = doubles = badpairs = 0

  prev = ''
  line.each_char do |c|
    vowels += 1 if %w[a e i o u].include?(c)
    doubles += 1 if c == prev
    badpairs +=1 if %w[ab cd pq xy].include?(prev + c)
    prev = c
  end
  vowels >= 3 && doubles >= 1 && badpairs.zero?
end

nice = 0
File.readlines('input.txt').each do |line|
  line.strip!
  nice += 1 if nice_word(line)
end

puts "nice: #{nice}"

def nicer_word(line)
  prevprev = ''
  prev = ''
  sandwich = false
  pairmatch = false
  pairs = Hash.new { |h, k| h[k] = [] }
  line.each_char.with_index do |c, i|
    sandwich ||= (prevprev == c) if i >= 2
    if i >= 1
      pair = prev + c
      pairmatch ||= pairs[pair].any? { |e| e <= (i - 3) }
      pairs[pair] << i - 1
    end
    prevprev = prev
    prev = c
  end
  sandwich && pairmatch
end

nicer = 0
File.readlines('input.txt').each do |line|
  line.strip!
  nicer += 1 if nicer_word(line)
end

puts "nicer: #{nicer}"
