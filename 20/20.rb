$goal = 36000000

def sum(n)
  factors = [1, n] + (2..n/2).to_a.delete_if { |x| n % x != 0 }
  10 * factors.inject(0) { |sum, f| sum + f }
end

def seive(goal)
  sums = Array.new(goal / 10 + 1, 1)
  first = 10
  house = 1
  while first < goal
    if house % 10000 == 0
      puts "#{first} #{house}"
    end
    house += 1
    (house...sums.length).step(house).each do |i|
      sums[i - 1] += house
    end
    first = sums[house - 1] * 10
  end
  house
end

def scan(goal)
  sum = 0
  house = 1
  while sum < goal
    n = house / 2
    sum = (((n + 1) * n) / 2) + house
    sum *= 10
    house += 1
  end
  house - 1
end

def run()
  house = 1
  while sum(house) < $goal
    house += 1
    if (house % 1000) == 0
      p house
    end
  end
  house
end
