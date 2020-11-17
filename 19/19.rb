require 'set'

def get_concoctions(compound, formulae)
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
  concoctions
end

def get_components(compound, formulae)
  components = Set.new
  formulae.each do |k, v|
    v.each do |v|
      positions = compound.enum_for(:scan, v).map { Regexp.last_match.begin(0) }
      positions.each do |position|
        component = compound.dup()
        component[position..position + (v.length - 1)] = k
        components.add(component)
      end
    end
  end
  components
end

def find_steps(desired, formulae)
  steps = 0
  concoctions = Set.new(['e'])
  while !concoctions.include?(desired) && steps < 10
    p steps
    p concoctions.size
    next_concoctions = Set.new
    concoctions.each do |concoction|
      next_concoctions = next_concoctions | get_concoctions(concoction, formulae)
    end
    next_concoctions.delete_if { |c| c.length > desired.length }
    concoctions = next_concoctions
    steps += 1
  end
  steps
end

def get_formulae(f)
  formulae = Hash.new { |h, k| h[k] = Array.new }
  File.readlines(f).each do |line|
    line.strip!
    formula = line.match(/(?<input>\w+) => (?<output>\w+)/)
    if !formula.nil?
      formulae[formula[:input]] << formula[:output]
    end
  end
  formulae  
end

def find_beginning(desired, formulae)
  steps = 0
  concoctions = Set.new([desired])
  while !concoctions.include?('e') && !concoctions.empty? && steps < 2
    p concoctions
    next_concoctions = Set.new
    concoctions.each do |concoction|
      next_concoctions = next_concoctions | get_components(concoction, formulae)
    end
    concoctions = next_concoctions
    steps += 1
  end
  steps
end

def reduce(desired, formulae)
  steps = 0
  sources = formulae['e']
  compound = desired.dup()
  while !sources.include? compound
    p steps
    p compound
    formulae.each do |k, v|
      if k != 'e'
        v.each do |v|
          positions = compound.enum_for(:scan, v).map { Regexp.last_match.begin(0) }
          compound.gsub!(v, k)
          steps += positions.length
        end
      end
    end
  end

  steps + 1
end

def run(f)
  formulae = get_formulae(f)
  compound = ''
  File.readlines(f).each do |line|
    line.strip!
    if !line.empty?
      formula = line.match(/=>/)
      if formula.nil?
        compound = line
      end
    end
  end

  
  concoctions = get_concoctions(compound, formulae)
  concoctions.size
end
