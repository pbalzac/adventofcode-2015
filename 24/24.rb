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

def recurse(nums, weight, size, start, remaining)
  groups = []
  found = false
  min_length_groups = []
  if size == start
    min_length_groups = choose(nums, size).filter { |g| check(g, weight) }
    start += 1
  end
  if min_length_groups.any?
    puts "Found min_length_groups.length #{min_length_groups.length} remaining #{remaining} nums.length #{nums.length}"
    if remaining == 1
      min_length_groups.each do |g|
        r = [g]
        if size * 2 == nums.length
          r += (nums - g)
        end
        groups << r
        found = true
      end
    else
      min_length_groups.each do |g|
        sub_result = recurse(nums - g, weight, size, size, remaining - 1)
        if sub_result[:found]
          sub_result[:groups].each do |sg|
            r = [g]
            groups << (r + sg)
          end
          found = true
        end
      end
    end
    p groups
  else
    steps = (nums.length - (remaining + 1) * start) / (remaining + 1)
    puts "steps #{steps}"
    if remaining == 1
      (0..steps).each do |step|
        to_check = choose(nums, start + step).find { |g| check(g, weight) }
        if !to_check.nil?
          found = true
          break
        end
      end
    else
      (0..steps).each do |step|
        break if found
        step_checks = choose(nums, start + step).filter { |g| check(g, weight) }
        if step_checks.any?
          step_checks.each do |step_check|
            sub_result = recurse(nums - step_check, weight,
                                 size, start + step, remaining - 1)
            if sub_result[:found]
              found = true
              break
            end
          end
        end
      end
    end
  end

  {
    found: found,
    groups: groups
  }
end

def recurse_bool(nums, weight, start, remaining)
  found = false
  steps = (nums.length - (remaining + 1) * start) / (remaining + 1)
    if remaining == 1
      (0..steps).each do |step|
        to_check = choose(nums, start + step).find { |g| check(g, weight) }
        if !to_check.nil?
          found = true
          break
        end
      end
    else
      (0..steps).each do |step|
        break if found
        step_checks = choose(nums, start + step).filter { |g| check(g, weight) }
        if step_checks.any?
          step_checks.each do |step_check|
            found = recurse_bool(nums - step_check, weight, start + step, remaining - 1)
            break if found
          end
        end
      end
    end
    found
end

def general_bool(nums, x)
  results = []
  total = nums.reduce(&:+)
  weight = total / x
  puts "TOTAL WEIGHT #{total} PER GROUP #{weight}"
  (1..nums.length / x).each do |n|
    break if results.any?
    puts "Checking #{n}"

    group_ones = choose(nums, n).filter { |g| check(g, weight) }
    group_ones.each do |g|
      if recurse_bool(nums - g, weight, n, x - 2)
        results << g
      end
    end
  end  
  results
end

def results_2(nums, x)
  r = general_bool(nums, x)
  m = r.min_by { |a| quantum_entanglement(a) }
  quantum_entanglement(m)
end

def general(nums, x)
  result = []
  total = nums.reduce(&:+)
  weight = total / x
  puts "TOTAL WEIGHT #{total} PER GROUP #{weight}"

  (1..nums.length / x).each do |n|
    return result if result.any?
    puts "Checking #{n}"
    sub_result = recurse(nums, weight, n, n, x - 1)
    if sub_result[:found]
      result = sub_result[:groups]
    end
  end
  
  result
end

def results(groups)
  minimums = groups.map { |s| s.min_by { |a| quantum_entanglement(a) } }
  group_one = minimums.min_by { |a| quantum_entanglement(a) }
  p group_one
  quantum_entanglement(group_one)
end

def run(f)
  nums = []
  File.readlines(f).each do |line|
    line.strip!
    nums << line.to_i
  end
  nums
end
    
