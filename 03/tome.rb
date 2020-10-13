x = 0
y = 0
rx = 0
ry = 0
houses = {}

def coords(x, y)
  "#{x},#{y}"
end

def visit(houses, x, y)
  c = coords(x, y)
  if houses[c]
    houses[c] += 1
  else
    houses[c] = 1
  end
end

visit(houses, x, y)
visit(houses, rx, ry)

directions = ''
File.readlines('input.txt').each do |line|
  directions = line.strip
end

directions.each_char.with_index do |c, i|
  if i % 2 == 1
    case c
    when '>'
      x += 1
    when '<'
      x -= 1
    when '^'
      y += 1
    when 'v'
      y -= 1
    else
      puts 'ERROR'
    end
    visit(houses, x, y)
  else
    case c
    when '>'
      rx += 1
    when '<'
      rx -= 1
    when '^'
      ry += 1
    when 'v'
      ry -= 1
    else
      puts 'ERROR'
    end
    visit(houses, rx, ry)
  end
end

puts houses.size
