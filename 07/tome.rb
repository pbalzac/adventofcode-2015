def binaryOp(op, v1, v2)
  case op
  when :and then v1 & v2
  when :or then v1 | v2
  when :rshift then v1 >> v2
  when :lshift then v1 << v2
  end
end

def unaryOp(op, v)
  case op
  when :not then
    ~v & 0xffff
  when :assign then v
  end
end

def getValue(wires, v)
  if v.match(/\d+/)
    v.to_i
  else
    wires[v].value
  end
end

class Wire
  attr_accessor :name
  attr_accessor :value
  attr_accessor :op
  attr_accessor :input1
  attr_accessor :input2

  def to_s
    "#{@name}: v(#{value}) o (#{@op}) i1 (#{@input1}) i2 (#{@input2})"
  end

  def evaluate(wires)
    if @value
      @value
    elsif @input1 && @input2
      v1 = getValue(wires, @input1)
      v2 = getValue(wires, @input2)
      if v1 && v2
        @value = binaryOp(@op, v1, v2)
      end
    else
      v1 = getValue(wires, @input1)
      if v1
        @value = unaryOp(@op, v1)
      end
    end
    @value
  end
end

wires = {}


def getOp(s)
  case s
  when 'AND' then :and
  when 'OR' then :or
  when 'LSHIFT' then :lshift
  when 'RSHIFT' then :rshift
  when 'NOT' then :not
  else :unknown
  end
end

File.readlines('input.txt').each do |line|
  line.strip!
  assignment = line.match(/(?<input>\w+) -> (?<wire>\w+)/)
  unary = line.match(/(?<op>\w+) (?<input>\w+) -> (?<wire>\w+)/)
  binary = line.match(/(?<input1>\w+) (?<op>\w+) (?<input2>\w+) -> (?<wire>\w+)/)  
  if assignment
    wires[assignment[:wire]] = Wire.new
    wires[assignment[:wire]].name = assignment[:wire]
    wires[assignment[:wire]].input1 = assignment[:input]
    wires[assignment[:wire]].op = :assign
  end    
  if unary
    wires[unary[:wire]] = Wire.new
    wires[unary[:wire]].name = unary[:wire]
    wires[unary[:wire]].op = getOp(unary[:op])
    wires[unary[:wire]].input1 = unary[:input]
  end    
  if binary
    wires[binary[:wire]] = Wire.new
    wires[binary[:wire]].name = binary[:wire]
    wires[binary[:wire]].op = getOp(binary[:op])
    wires[binary[:wire]].input1 = binary[:input1]
    wires[binary[:wire]].input2 = binary[:input2]
  end    
end

wires['b'].value = 956

evaluated = 0

while evaluated < wires.size
  evaluated = 0
  wires.each_value do |wire|
    if wire.evaluate(wires)
      evaluated += 1
    end
  end
  puts evaluated
end

puts wires['a']
