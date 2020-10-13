total = 0
ribbon = 0

def surface_area(l, w, h)
  2 * l * w + 2 * w * h + 2 * h * l
end

def smallest_area(l, w, h)
  [l * w, w * h, l * h].min
end

def volume(l, w, h)
  l * w * h
end

def smallest_perimeter(l, w, h)
  [2*l + 2*w, 2*l + 2*h, 2*w + 2*h].min
end

File.readlines('input.txt').each do |line|
  val = line.match(/(?<l>\d+)x(?<w>\d+)x(?<h>\d+)/)
  l = val[:l].to_i
  w = val[:w].to_i
  h = val[:h].to_i
  total += surface_area(l, w, h) + smallest_area(l, w, h)
  ribbon += smallest_perimeter(l, w, h) + volume(l, w, h)
end

puts total
puts ribbon
