require 'bitarray'
require 'chunky_png'

grid = Array.new(1000) { BitArray.new(1000) }

def apply(g, op, x1, y1, x2, y2)
  (y1.to_i..y2.to_i).each do |y|
    (x1.to_i..x2.to_i).each do |x|
      case op
      when :on
        g[y][x] = 1
      when :off
        g[y][x] = 0
      when :toggle
        g[y][x] = g[y][x].zero? ? 1 : 0
      end
    end
  end
end

def count(g)
  c = 0
  g.each do |row|
    c += row.total_set
  end
  c
end

puts "initial count #{count(grid)}"

File.readlines('input.txt').each do |line|
  val = line.match(/turn (?<state>\w+) (?<x1>\d+),(?<y1>\d+) through (?<x2>\d+),(?<y2>\d+)/)
  if val
    op = if val[:state] == 'on' then :on else :off end
    apply(grid, op, val[:x1], val[:y1], val[:x2], val[:y2])
  else
    val = line.match(/toggle (?<x1>\d+),(?<y1>\d+) through (?<x2>\d+),(?<y2>\d+)/)
    if val
      apply(grid, :toggle, val[:x1], val[:y1], val[:x2], val[:y2])
    end
  end
end

puts "final count #{count(grid)}"

png = ChunkyPNG::Image.new(1010, 1010, ChunkyPNG::Color::BLACK)

(0..999).each do |y|
  (0..999).each do |x|
    c = grid[y][x].zero? ? ChunkyPNG::Color('blue') : ChunkyPNG::Color('green')
    png[5 + y, 5 + x] = c
  end
end

png.save('image.png')
