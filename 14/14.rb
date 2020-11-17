class Reindeer
  attr_accessor :name
  attr_accessor :speed
  attr_accessor :fly
  attr_accessor :rest
  attr_accessor :position
  attr_accessor :score
  
  def initialize(name, speed, fly, rest)
    @name = name
    @speed = speed.to_i
    @fly = fly.to_i
    @rest = rest.to_i
    @position = 0
    @score = 0
  end

  def location(time)
    distance = 0
    distance += (@speed * @fly) * (time / (@fly + @rest))
    remaining = time % (@fly + @rest)
    distance += (@speed) * [remaining, @fly].min
    @position = distance
    @position
  end

  def update_score(max)
    @score += 1 if @position == max
  end
  
end

def run(f, t)
  racers = Hash.new
  File.readlines(f).each do |line|
    line.strip!
    stats = line.match(/(?<reindeer>\w+) can fly (?<speed>\d+) km\/s for (?<time>\d+) seconds, but then must rest for (?<rest>\d+) seconds\./)
    racers[stats[:reindeer]] = Reindeer.new stats[:reindeer], stats[:speed], stats[:time], stats[:rest]
  end
  times = racers.values.map { |racer| racer.location(t) }
  p times
end

def run2(f, t)
  racers = Hash.new
  File.readlines(f).each do |line|
    line.strip!
    stats = line.match(/(?<reindeer>\w+) can fly (?<speed>\d+) km\/s for (?<time>\d+) seconds, but then must rest for (?<rest>\d+) seconds\./)
    racers[stats[:reindeer]] = Reindeer.new stats[:reindeer], stats[:speed], stats[:time], stats[:rest]
  end
  (1..t).each do |i|
    max = racers.values.map { |racer| racer.location(i) }.max
    racers.values.map { |racer| racer.update_score(max) }
  end
  scores = racers.values.map(&:score)
end
