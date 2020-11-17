class City
  attr_accessor :name
  attr_accessor :connections

  def initialize(name)
    @name = name
    @connections = {}
  end

  def add_connection(name, distance)
    @connections[name] = distance
  end
  
end

cities = Hash.new { |h, k| h[k] = City.new(k) }
File.readlines('input.txt').each do |line|
  directions = line.match(/(?<city1>\w+) to (?<city2>\w+) = (?<distance>\d+)/)
  city1 = directions[:city1]
  city2 = directions[:city2]
  distance = directions[:distance].to_i
  
  cities[city1].add_connection(city2, distance)
  cities[city2].add_connection(city1, distance)
end

puts cities

def permutate(a)
  return [a] if a.size == 1

  r = []
  a.each do |e|
    l = a - [e]
    permutate(l).each do |perm|
      r << ([e] + perm)
    end
  end

  r
end

shortest = 2147483647
routes = permutate(cities.keys)

routes.each do |route|
  distance = 0
  (1...route.size).each do |i|
    distance += cities[route[i]].connections[route[i - 1]]
    break if distance > shortest
  end
  shortest = distance if distance < shortest
end

longest = 0
routes.each do |route|
  distance = 0
  (1...route.size).each do |i|
    distance += cities[route[i]].connections[route[i - 1]]
  end
  longest = distance if distance > longest
end

puts shortest
puts longest

