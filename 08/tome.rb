total = 0
memory = 0
expand = 0

def count_chars(s)
  t = s[1..-2]
  t.gsub!(/\\x[0-9a-f][0-9a-f]/, 'x')
  t.gsub!(/\\\\/, '\\')
  t.gsub!(/\\"/, '"')
  puts "#{s} - - - #{t}"
  t.size
end

def expand_chars(s)
  t = s.clone
  t.gsub!(/\\/, '\\\\\\')
  t.gsub!(/"/, '\\"')
  puts "#{s} - - - #{t}"
  2 + t.size
end

File.readlines('input.txt').each do |line|
  line.strip!
  memory += line.size
  total += count_chars(line)
  expand += expand_chars(line)
end

puts memory
puts total
puts expand
puts memory - total
puts expand - memory
