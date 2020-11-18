class Character
  attr_accessor :hp
  attr_accessor :outfit
  attr_accessor :damage
  attr_accessor :armor
  attr_accessor :life

  def initialize(hp, damage = 0, armor = 0)
    @hp = hp
    @damage = damage
    @armor = armor
    @life = @hp
    @outfit = []
  end

  def revive
    @life = @hp
  end

  def wear_outfit(outfit)
    @outfit = outfit
    @armor = outfit.inject(0) { |armor, item| armor + item.armor }
    @damage = outfit.inject(0) { |damage, item| damage + item.damage }
  end

  def suffer_hit(attack)
    @life -= [attack - armor, 1].max
  end

  def dead?
    @life <= 0
  end
  
end
  
class Item
  attr_accessor :name
  attr_accessor :cost
  attr_accessor :damage
  attr_accessor :armor

  def initialize(n, c, d, a)
    @name = n
    @cost = c
    @damage = d
    @armor = a
  end

  def to_s
    @name
  end
end

def load_items(file)
  items = []
  File.readlines(file).each do |line|
    line.strip!
    stats = line.match(/(?<name>.*)\s+(?<cost>\d+)\s+(?<damage>\d+)\s+(?<armor>\d+)/)
    items << Item.new(stats[:name].strip, stats[:cost].to_i, stats[:damage].to_i, stats[:armor].to_i)
 end
  items
end

def battle(boss, player)
  while true
    boss.suffer_hit(player.damage)
    return true if boss.dead?
    player.suffer_hit(boss.damage)
    return false if player.dead?
  end
end

def pairs(a)
  r = []
  (0...a.length - 1).each do |i|
    (i + 1...a.length).each do |j|
      r << [a[i], a[j]]
    end
  end
  r
end

def run
  weapons = load_items('weapons.txt')
  armor = load_items('armor.txt')
  rings = load_items('rings.txt')

  outfits = []
  (weapons.map{ |w| [w] }).each do |w|
    ((armor.map{ |a| [a] }) + [[]]).each do |a|
      ((rings.map{ |r| [r]}) + [[]] + pairs(rings)).each do |r|
        outfits << w + a + r
      end
    end
  end

  gold_to_win = -1
  gold_to_lose = -1
  outfits.each.with_index do |o, i|
    boss = Character.new(104, 8, 1)
    player = Character.new(100)
    player.wear_outfit o
    gold = o.inject(0) { |gold, item| gold + item.cost }
    if battle(boss, player)
      gold_to_win = gold_to_win == -1 ? gold : [gold, gold_to_win].min
    else
      gold_to_lose = [gold, gold_to_lose].max
    end
  end

  puts "least to win #{gold_to_win} most to lose #{gold_to_lose}"
end
