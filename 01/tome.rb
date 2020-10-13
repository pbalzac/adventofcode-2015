puts 'hi'

s = 'hi'

File.readlines('input.txt').each_with_index do |line, i|
  s = line.strip
end

floor = 0
s.each_char.with_index do |c, i|
  if c == '('
    floor += 1
  else
    floor -= 1
  end
  puts i + 1 if floor == -1
end
puts floor
