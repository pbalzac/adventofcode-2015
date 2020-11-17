require 'set'

def run(f)
  formulae = Hash.new { |h, k| h[k] = Array.new }
  compound = ''
  File.readlines(f).each do |line|
    line.strip!
    if !line.empty?
      formula = line.match(/(?<input>\w+) => (?<output>\w+)/)
      if !formula.nil?
        formulae[formula[:input]] << formula[:output]
      else
        compound = line
      end
    end
  end

  concoctions = Set.new
  formulae.each do |k, v|
    positions = compound.enum_for(:scan, k).map { Regexp.last_match.begin(0) }
    v.each do |v|
      positions.each do |position|
        concoction = compound.dup()
        concoction[position..position + (k.length - 1)] = v
        concoctions.add(concoction)
      end
    end
  end
  concoctions.size
end
