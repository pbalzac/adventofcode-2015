def quantum_entanglement(a)
  a.inject(1) { |p, e| p * e }
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

def check(a, w)
  return false if a[0] * a.length > w
  return false if a[a.length - 1] * a.length < w
  a.reduce(&:+) == w
end

def smallest(nums)
  result = []
  total = nums.reduce(&:+)
  weight = total / 3
  puts "TOTAL WEIGHT #{total} PER GROUP #{weight}"

  (1..nums.length / 3).each do |n|
    return result if result.any?
    
    group_ones = choose(nums, n).filter { |g| check(g, weight) }
    if group_ones.any?
      group_ones.each.with_index do |g1, i|
        # check same size groups
        group_twos = choose(nums - g1, n).filter { |g| check(g, weight) }
        if group_twos.any?
          group_twos.each do |g2|
            r = [g1, g2]
            if 3 * n == nums.length
              r << (nums - g1 - g2)
            end
            result << r
          end
        else
          (n + 1..n + ((nums.length - 3 * n) / 2)).each do |m|
             group_two = choose(nums - g1, m).find { |g| check(g, weight) }
             if !group_two.nil?
               result << [g1]
               break
             end
           end
        end
      end
    end
  end
  result
end

def run(f)
  nums = []
  File.readlines(f).each do |line|
    line.strip!
    nums << line.to_i
  end

  minimums = smallest(nums).map { |s| s.min_by { |a| quantum_entanglement(a) } }
  group_one = minimums.min_by { |a| quantum_entanglement(a) }
  p group_one
  quantum_entanglement(group_one)
end
    
