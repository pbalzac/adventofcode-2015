class Ingredient
  attr_accessor :name
  attr_accessor :capacity
  attr_accessor :durability
  attr_accessor :flavor
  attr_accessor :texture
  attr_accessor :calories

  def initialize(name, cap, dur, fla, tex, cal)
    @name = name
    @capacity = cap
    @durability = dur
    @flavor = fla
    @texture = tex
    @calories = cal
  end
  
end

def recipes(buckets, total)
  return [[total]] if buckets == 1

  r = []
  (0..total).each do |n|
    recipes(buckets - 1, total - n).each do |sub|
      r << [n] + sub
    end
  end

  r
end

def run(f, total, target)
  ingredients = []
  File.readlines(f).each do |line|
    line.strip!
    ingredient = line.match(/(?<ingredient>\w+): capacity (?<cap>-?\d+), durability (?<dur>-?\d+), flavor (?<fla>-?\d+), texture (?<tex>-?\d+), calories (?<cal>-?\d+)/)
    ingredients << Ingredient.new(ingredient[:ingredient], ingredient[:cap].to_i,
                                  ingredient[:dur].to_i, ingredient[:fla].to_i,
                                  ingredient[:tex].to_i, ingredient[:cal].to_i)
  end

  recipes = recipes(ingredients.length, total)
  best_recipe = 0
  properties = [Ingredient.instance_method(:capacity),
                Ingredient.instance_method(:durability),
                Ingredient.instance_method(:flavor),
                Ingredient.instance_method(:texture)]
  calories_property = Ingredient.instance_method(:calories)
  recipes.each do |recipe|
    calories = recipe.each.with_index.inject(0) do | sum, (amount, ingredient) |
      sum += amount * calories_property.bind(ingredients[ingredient]).call()
    end
    if calories == target
      recipe_score = 1
      properties.each do |property|
        property_score = 0
        recipe.each.with_index do |amount, ingredient|
          property_score += amount * property.bind(ingredients[ingredient]).call()
        end
        property_score = [property_score, 0].max
        recipe_score *= property_score
      end
      best_recipe = [recipe_score, best_recipe].max
    end
  end
  best_recipe
end
