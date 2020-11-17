def choose(elements, n)
  return elements.map { |e| [e] } if n == 1

  r = Array.new
  size = elements.length
  (0..size - n).each do |i|
    choose(elements.slice(i + 1, size - i - 1), n - 1).each do |c|
      r << [elements[i]] + c
    end
  end
  
  r
end

def all_combos(elements)
  r = Array.new

  (1..elements.size).each do |n|
    r += choose(elements, n)
  end

  r
end

def run(f, total)
  buckets = Array.new
  File.readlines(f).each do |line|
    line.strip!
    buckets << line.to_i
  end
  combos = all_combos(buckets)
  results = combos.select { |a| (a.inject(0){|sum, x| sum + x}) == total }
  p results.size
  stats = results.inject(Hash.new { |h, k| h[k] = 0 }) { |h, a| h[a.length] += 1; h }
  p stats
end
