class Favor
  attr_accessor :person
  attr_accessor :amount

  def initialize(person, amount)
    @person = person
    @amount = amount
  end
end

class Person
  attr_accessor :name
  attr_accessor :favor

  def initialize(name)
    @name = name
    @favor = {}
  end

  def add_favor(other, direction, amount)
    factor = direction == 'lose' ? -1 : 1
    favor[other] =  Favor.new other, factor * amount.to_i
  end
  
end

def permute(list)
  return [list] if list.length == 1

  r = []
  list.each do |e|
    l = list - [e]
    permute(l).each do |permutation|
      r << ([e] + permutation)
    end
  end

  r
end

def seatings(persons)
  head = persons.slice(0)
  rest = permute(persons.slice(1, persons.length - 1))
  # remove rotations
  undirectional = []
  rest.each do |r|
    if !(undirectional.include? r.reverse)
      undirectional << r
    end
  end
  undirectional.map { |u| [head] + u }
end

def score(seatings, people)
  seatings.map do |s|
    score = 0
    (1...s.length).each do |i|
      score += people[s[i]].favor[s[i - 1]].amount
      score += people[s[i - 1]].favor[s[i]].amount
    end
    score += people[s[s.length - 1]].favor[s[0]].amount
    score += people[s[0]].favor[s[s.length - 1]].amount
    score
  end
end

def alternate_scoring(seatings, people)
  seatings.flat_map do |s|
    score = 0
    (1...s.length).each do |i|
      score += people[s[i]].favor[s[i - 1]].amount
      score += people[s[i - 1]].favor[s[i]].amount
    end
    score += people[s[s.length - 1]].favor[s[0]].amount
    score += people[s[0]].favor[s[s.length - 1]].amount
    
    alternate_scores = []
    (1...s.length).each do |i|
      alt = score
      alt -= people[s[i]].favor[s[i - 1]].amount
      alt -= people[s[i - 1]].favor[s[i]].amount
      alternate_scores << alt
    end
    alt = score
    alt -= people[s[s.length - 1]].favor[s[0]].amount
    alt -= people[s[0]].favor[s[s.length - 1]].amount
    alternate_scores << alt
    alternate_scores
  end
end

def run(f)
  people = Hash.new { |h, k| h[k] = Person.new(k) }
  File.readlines(f).each do |line|
    line.strip!
    extract = line.match(/(?<person>\w+) would (?<direction>\w+) (?<amount>\d+) happiness units by sitting next to (?<partner>\w+)\./)
    people[extract[:person]].add_favor(extract[:partner], extract[:direction], extract[:amount])
  end
  seatings = seatings(people.keys)
  scores = score(seatings, people)
  p scores.length
  p scores.max
  # works but is very slow
  # zac = Person.new('Zac')
  # people.values.each do |person|
  #   zac.add_favor(person.name, 'increase', 0)
  #   person.add_favor(zac.name, 'increase', 0)
  # end
  # people['Zac'] = zac
  # seatings = seatings(people.keys)
  # scores = score(seatings, people)
  # p scores.max
  # much faster
  alternate_scores = alternate_scoring(seatings, people)
  p alternate_scores.length
  p alternate_scores.max
end
