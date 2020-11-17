require 'bitarray'

def count(g)
  c = 0
  g.each do |row|
    c += row.total_set
  end
  c
end

def neighbors(grid, x, y)
  left = x == 0
  right = x == grid.length - 1
  top = y == 0
  bottom = y == grid.length - 1

  r = 0
  if !top
    r += grid[y - 1][x - 1] if !left
    r += grid[y - 1][x]
    r += grid[y - 1][x + 1] if !right
  end
  r += grid[y][x - 1] if !left
  r += grid[y][x + 1] if !right
  if !bottom
    r += grid[y + 1][x - 1] if !left
    r += grid[y + 1][x]
    r += grid[y + 1][x + 1] if !right
  end
  
  r            
end

def advance(input)
  result = Array.new(input.length) { BitArray.new(input.length) }
  (0...input.length).each do |y|
    (0...input.length).each do |x|
      neighbors = neighbors(input, x, y)
      if (input[y][x] == 1 && neighbors == 2) || neighbors == 3
        result[y][x] = 1
      end
    end
  end
  result
end

def advance(input)
  result = Array.new(input.length) { BitArray.new(input.length) }
  (0...input.length).each do |y|
    (0...input.length).each do |x|
      neighbors = neighbors(input, x, y)
      if (input[y][x] == 1 && neighbors == 2) || neighbors == 3
        result[y][x] = 1
      end
    end
  end
  result
end

def getgrid(f, size)
  grid = Array.new(size) { BitArray.new(size) }
  File.readlines(f).each.with_index do |line, i|
    line.strip!
    line.each_char.with_index do |c, j|
      grid[i][j] = 1 if c == '#'
    end
  end
  grid
end

def set_corners(grid)
  s = grid.length - 1
  grid[0][0] = grid[0][s] = grid[s][0] = grid[s][s] = 1
end

def run(f, size, steps)
  grid = getgrid(f, size)
  set_corners(grid)
  steps.times do
    grid = advance(grid)
    set_corners(grid)    
  end
  count(grid)
end
