class Sue

  attr_accessor :number
  attr_accessor :counts

  def initialize(number)
    @number = number
    @counts = Hash.new
  end

end

def run(f, e)
  sues = []
  File.readlines(f).each do |line|
    line.strip!
    stats = line.match(/Sue (?<sue>\d+): (?<s1>\w+): (?<sc1>\d+), (?<s2>\w+): (?<sc2>\d+), (?<s3>\w+): (?<sc3>\d+)/)
    sue = Sue.new(stats[:sue])
    sue.counts[stats[:s1]] = stats[:sc1].to_i
    sue.counts[stats[:s2]] = stats[:sc2].to_i
    sue.counts[stats[:s3]] = stats[:sc3].to_i
    sues << sue
  end
  evidence = Hash.new
  ops = Hash.new
  File.readlines(e).each do |line|
    line.strip!
    clue = line.match(/(?<category>\w+): (?<count>\d+)/)
    category = clue[:category]
    evidence[category] = clue[:count].to_i
    case category
    when 'cats', 'trees'
      ops[category] = proc { |x, y| x > y }
    when 'pomeranians', 'goldfish'
      ops[category] = proc { |x, y| x < y }
    else
      ops[category] = proc { |x, y| x == y }
    end
  end
  test1 = sues.clone()
  test2 = sues.clone()
  while test1.length > 1
    evidence.each do |k, v|
      test1.select! { |sue| sue.counts[k] == nil || sue.counts[k] == v }
    end
    p 'test1'
  end
  p test1
  while test2.length > 1
    evidence.each do |k, v|
      test2.select! { |sue| sue.counts[k] == nil || ops[k].call(sue.counts[k], v) }
    end
    p 'test2'
  end
  p test2
end
