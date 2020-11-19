class Character
  attr_accessor :hp
  attr_accessor :damage
  attr_accessor :armor
  attr_accessor :life

  def initialize(hp, damage = 0, armor = 0)
    @hp = hp
    @damage = damage
    @armor = armor
    @life = @hp
  end

  def revive
    @life = @hp
  end

  def suffer_hit(attack)
    @life -= [attack - armor, 1].max
  end

  def dead?
    @life <= 0
  end

  def take_turn(world)
    world.player.suffer_hit(@damage, world)
  end
end

class Effect
  attr_accessor :timer
  attr_accessor :effect_type
  attr_accessor :apply_me
  attr_accessor :amount

  def initialize(duration, effect_type:, apply_me: [], amount: 0)
    @timer = duration
    @effect_type = effect_type
    @apply_me = apply_me
    @amount = amount
  end

  def advance(world)
    timer -= 1
    apply_me.each { |a| a.call(world) }
  end

  def expired?
    timer == 0
  end
end

class Spell
  attr_accessor :name
  attr_accessor :cost
  attr_accessor :cast_me
  attr_accessor :effect_type

  def initialize(name, cost, cast_me:, effect_type: nil)
    @name = name
    @cost = cost
    @cast_me = cast_me
    @effect_type = effect_type
  end

  def cast(world)
    puts "Casting #{@name}"
    cast_me.each { |c| c.call(world) }
  end

  def can_cast?(world)
    return world.active_effects.none? { |a| a.effect_type == @effect_type }
  end
end

def damage_boss
  ->(amount, world) { world.boss.suffer_hit(amount) }
end
def heal_player
  ->(amount, world) { world.player.heal(amount) }
end
def focus_player
  ->(amount, world) { world.player.focus(amount) }
end
def shield(world)
  world.active_effects << Effect.new(6, effect_type: :SHIELD, amount: 7)
end
def poison(world)
  world.active.effects << Effect.new(6, effect_type: :POISON, apply_me: [damage_boss.curry(2)[3]])
end
def recharge(world)
  world.active_effects << Effect.new(5, effect_type: :RECHARGE, apply_me: [focus_player.curry(2)[101]])
end

$magic_missile = Spell.new('Magic Missile', 53, cast_me: [damage_boss.curry(2)[4]])
$drain = Spell.new('Drain', 73, cast_me: [damage_boss.curry(2)[2], heal_player.curry(2)[2]])
$shield = Spell.new('Shield', 113, effect_type: :SHIELD, cast_me: [method(:shield)])
$poison = Spell.new('Poison', 173, effect_type: :POISON, cast_me: [method(:poison)])
$recharge = Spell.new('Recharge', 229, effect_type: :RECHARGE, cast_me: [method(:recharge)])

class Player < Character
  attr_accessor :mana
  attr_accessor :spells

  def initialize(hp, damage = 0, armor = 0, mana: 0)
    super(hp, damage, armor)
    @mana = mana
  end

  def heal(amount)
    @life += amount
  end

  def focus(amount)
    @mana += amount
  end

  def take_turn(world)
    eligible = castable_spells(world)
    eligible[0].cast(world)
    @mana -= eligible[0].cost
  end

  def cannot_cast?(world)
    castable_spells(world).empty?
  end

  def castable_spells(world)
    @spells.select { |s| s.can_cast?(world) && @mana > s.cost }
  end
    
  def suffer_hit(attack, world)
    bonus = world.active_effects.inject(0) { |bonus, a| bonus + (a.effect_type == :SHIELD ? a.amount : 0) }
    @life -= [attack - armor - bonus, 1].max
  end
end

class World
  attr_accessor :player
  attr_accessor :boss
  attr_accessor :turn
  attr_accessor :active_effects

  def initialize(player, boss)
    @player = player
    @boss = boss
    @turn = :player_turn
    @active_effects = []
  end

  def advance
    apply_effects
    case @turn
    when :player_turn
      @player.take_turn(self)
      @turn = :boss_turn
    when :boss_turn
      @boss.take_turn(self)
      @turn = :player_turn
    end
    puts "Player life #{@player.life} Boss life #{@boss.life}"
  end

  def apply_effects
    @active_effects.each { |e| e.advance(self) }
    active_effects.delete_if { |e| e.expired? }
  end

  def game_over?
    return :boss_death if @boss.dead?
    return :player_death if @player.dead?
    return :bad_wizard if @player.cannot_cast?(self)
    :next_turn
  end
end

def make_world
  boss = Character.new(55, 8)
  player = Player.new(50, mana: 500)
  player.spells = [ $magic_missile, $drain, $shield, $poison, $recharge ]
  world = World.new(player, boss)
  world
end

def run(world)
  game_state = world.game_over?
  while game_state == :next_turn
    world.advance
    game_state = world.game_over?
  end
  game_state
end
