require 'json'

File.readlines('input.txt').each do |line|
  line.strip!
  nums = line.scan(/-?\d+/).flat_map(&:to_i)
  p nums.inject(0, &:+)
end

def sum_hash(json)
  s = 0
  flagged = false
  json.values.each do |v|
    if v.is_a? Numeric
      s += v.to_i
    elsif v.is_a? String
      flagged ||= v == 'red'
    else
      s += sum(v)
    end
  end
  flagged ? 0 : s
end  

def sum_array(json)
  s = 0
  json.each do |v|
    if v.is_a? Numeric
      s += v.to_i
    elsif !(v.is_a? String)
      s += sum(v)
    end
  end
  s
end

def sum(json)
  (json.is_a? Array) ? sum_array(json) : sum_hash(json)
end

File.readlines('input.txt').each do |line|
  line.strip!
  json = JSON.parse(line)
  p sum(json)
end
