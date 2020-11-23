$memory = []
$pc = 0
$registers = Hash.new
$registers[:a] = 0
$registers[:b] = 0

class Instruction
  attr_accessor :opcode
  attr_accessor :register
  attr_accessor :offset

  def initialize(opcode, register: nil, offset: 0)
    @opcode = opcode
    @register = register
    @offset = offset
  end

  def inspect
    "#{opcode} #{register} #{offset}"
  end

  def to_s
    inspect
  end
end

def compute
  while $pc >=0 && $pc < $memory.length
    puts "#{$pc} #{$memory[$pc]}"
    offset = execute($memory[$pc])
    $pc += offset
    puts $registers
  end
end

def execute(instruction)
  case instruction.opcode
  when :hlf
    $registers[instruction.register] /= 2
  when :tpl
    $registers[instruction.register] *= 3
  when :inc
    $registers[instruction.register] += 1
  when :jmp
    return instruction.offset
  when :jie
    return instruction.offset if $registers[instruction.register].even?
  when :jio
    return instruction.offset if $registers[instruction.register] == 1
  end
  1
end

def get_opcode(s)
  case s
  when "jio" then :jio
  when "inc" then :inc
  when "tpl" then :tpl
  when "hlf" then :hlf
  when "jmp" then :jmp
  when "jie" then :jie
  else :ERROR
  end
end

def get_register(s)
  s == "a" ? :a : :b
end

def clear
  $memory = []
  $registers = Hash.new
  $registers[:a] = 0
  $registers[:b] = 0
  $pc = 0
end

def run(f, a = 0, b = 0)
  clear
  $registers[:a] = a
  $registers[:b] = b
  File.readlines(f).each do |line|
    line.strip!
    unary = line.match(/(?<opcode>\w+) ((?<register>\w+)|(?<offset>[-+]?\d+))$/)
    binary = line.match(/(?<opcode>\w+) (?<register>\w), (?<offset>[-+]\d+)/)
    if !unary.nil?
      opcode = get_opcode(unary[:opcode])
      if unary[:register].nil?
        $memory << Instruction.new(opcode, offset: unary[:offset].to_i)
      else
        $memory << Instruction.new(opcode, register: get_register(unary[:register]))
      end
    elsif !binary.nil?
      $memory << Instruction.new(get_opcode(binary[:opcode]),
                                register: get_register(binary[:register]),
                                offset: binary[:offset].to_i)
    else
      puts "ERROR unknown format #{line}"
    end
  end
  compute
end
