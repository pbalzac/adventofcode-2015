$verbose = false
$always_damage = true

class Character
  attr_accessor :hp
  attr_accessor :damage
  attr_accessor :armor
  attr_accessor :life
  attr_accessor :name

  def initialize(name, hp, damage = 0, armor = 0)
    @name = name
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
    puts "#{name} attacks for #{damage} damage" if $verbose
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
    @timer -= 1
    @apply_me.each { |a| a.call(world) }
  end

  def expired?
    @timer == 0
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
#    puts "Casting #{@name}"
    @cast_me.each { |c| c.call(world) }
  end

  def can_cast?(world)
    return world.active_effects.none? { |a| a.effect_type == @effect_type }
  end

  def to_s
    name
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
  world.active_effects << Effect.new(6, effect_type: :POISON, apply_me: [damage_boss.curry(2)[3]])
end
def recharge(world)
  world.active_effects << Effect.new(5, effect_type: :RECHARGE, apply_me: [focus_player.curry(2)[101]])
end

$magic_missile = Spell.new('Magic Missile', 53, cast_me: [damage_boss.curry(2)[4]])
$drain = Spell.new('Drain', 73, cast_me: [damage_boss.curry(2)[2], heal_player.curry(2)[2]])
$shield = Spell.new('Shield', 113, effect_type: :SHIELD, cast_me: [method(:shield)])
$poison = Spell.new('Poison', 173, effect_type: :POISON, cast_me: [method(:poison)])
$recharge = Spell.new('Recharge', 229, effect_type: :RECHARGE, cast_me: [method(:recharge)])
$spells = [ $magic_missile, $drain, $shield, $poison, $recharge ]

class Player < Character
  attr_accessor :mana

  def initialize(name, hp, mana = 0)
    super(name, hp)
    @mana = mana
  end

  def heal(amount)
    @life += amount
  end

  def focus(amount)
    @mana += amount
  end

  def take_turn(world)
    next_spell = world.next_spell(self)
    next_spell.cast(world)
    @mana -= next_spell.cost
  end

  def cannot_cast?(world)
    world.castable(@mana).empty?
  end

  def suffer_hit(attack, world)
    @life -= [attack - defense(world), 1].max
  end

  def defense(world)
    bonus = world.active_effects.inject(0) { |bonus, a| bonus + (a.effect_type == :SHIELD ? a.amount : 0) }
    armor + bonus
  end
end

class Move
  attr_accessor :explored
  attr_accessor :result
  attr_accessor :moves
  attr_accessor :spell
  attr_accessor :previous
  attr_accessor :mana_spent

  def initialize(spell = nil, previous = nil)
    @explored = false
    @moves = []
    @spell = spell
    @previous = previous
    @mana_spent = 0
    if !@spell.nil? && !@previous.nil?
      @mana_spent = @spell.cost + @previous.mana_spent
    end
  end

  def next_move(player, world)
    if @moves.empty?
      castable = world.castable(player.mana)
      castable.each { |c| @moves << Move.new(c, self) }
    end
    @moves.find { |m| !m.explored }
  end

  def set_result(result)
    @result = result
    @explored = true
    @previous.check_explored
  end

  def check_explored
    if @moves.all? { |m| m.explored }
      @explored = true
      @previous.check_explored if !@previous.nil?
    end
  end

  def to_s
    "Move #{spell.to_s} #{result} #{explored}"
  end

  def inspect
    to_s
  end
end

class World
  attr_accessor :player
  attr_accessor :boss
  attr_accessor :turn
  attr_accessor :active_effects
  attr_accessor :start_move
  attr_accessor :current_move
  attr_accessor :original_player
  attr_accessor :original_boss
  attr_accessor :results

  def initialize(player, boss)
    @player = player
    @boss = boss
    @turn = :player_turn
    @active_effects = []
    @start_move = Move.new
    @original_player = player.clone()
    @original_boss = boss.clone()
    @current_move = @start_move
    @results = Hash.new { |h, k| h[k] = [] }
  end

  def advance
    # puts "-- #{@turn == :player_turn ? 'Player' : 'Boss'} turn --"
    # puts "- Player has #{@player.life} hit points, #{@player.defense(self)} armor, #{@player.mana} mana"
    # puts "- Boss has #{@boss.life} hit points"
    # puts
    if $always_damage && @turn == :player_turn
      @player.life -= 1
      return if @player.dead?
    end

    apply_effects
    case @turn
    when :player_turn
      @player.take_turn(self)
      @turn = :boss_turn
    when :boss_turn
      @boss.take_turn(self)
      @turn = :player_turn
    end
  end

  def apply_effects
    @active_effects.each { |e| e.advance(self) }
    @active_effects.delete_if { |e| e.expired? }
  end

  def game_over?
    return :boss_death if @boss.dead?
    return :player_death if @player.dead?
    return :bad_wizard if @player.cannot_cast?(self)
    :next_turn
  end

  def castable(mana)
    $spells.select { |s| (s.can_cast?(self) && mana >= s.cost) }
  end

  def next_spell(player)
    @current_move = @current_move.next_move(player, self)
    @current_move.spell
  end

  def run(min_mana)
    game_state = game_over?
    while game_state == :next_turn
      advance
      game_state = game_over?
      return :too_costly if @current_move.mana_spent > min_mana
    end
    game_state
  end

  def simulate
    runs = 0
    min_mana = 10000000
    while !@start_move.explored
      puts "#{runs} SIMULATIONS" if runs % 1000 == 0
      result = run(min_mana)
      @current_move.set_result(result)
      @results[result] << @current_move
      if result == :boss_death
        min_mana = [ min_mana, @current_move.mana_spent ].min
      end
      reset_world
      runs += 1
    end
    min_mana
  end

  def manual(moves)
    
  end

  def reset_world
    @active_effects = []
    @current_move = @start_move
    @player = @original_player.clone()
    @boss = @original_boss.clone()
    @turn = :player_turn
  end
end

def make_world(boss_health = 55, boss_damage = 8, player_health = 50, player_mana = 500)
  boss = Character.new('Boss', boss_health, boss_damage)
  player = Player.new('Player', player_health, player_mana)
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
