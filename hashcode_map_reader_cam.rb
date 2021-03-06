#!env ruby

require 'pry'
require 'awesome_print'

class Validator
  def initialize(rules)

  end

  def validate(piece)

  end
end

class Node
  attr_accessor :decision, :parent, :own_score, :score_total, :slice_tally, :weight, :map, :info, :min_ingredient_tally
  @@node_count = 0


  def initialize(decision, parent, map, info, min_ingredient_count) #{piece: {x: 1, y, 1}, placement: {x: 1, y: 1}}
    @decision = decision
    @parent = parent
    @own_score = decision[:piece][:x] * decision[:piece][:y] #number of segements in decision
    @score_total = (@parent.score_total rescue 0) + @own_score
    @slice_tally = (@parent.slice_tally rescue 0) + 1
    @min_ingredient_tally = (@parent.min_ingredient_tally rescue 0) + min_ingredient_count
    @weight = @score_total.to_f / min_ingredient_tally.to_f
    @map = map.map{|x| x.clone}
    @info = info
    if @score_total == info.size
      $found_solution = true
    end
    puts ""
    puts self.weight
    puts self.score_total
    puts ""
  end

  def self.explore(pieces, initial_map, info)
    results = []
    position_x = info.marker[:x]
    position_y = info.marker[:y]
    pieces.each do |piece|
      current_map = initial_map.map(&:clone)
      temp_piece = []
      (position_x..(piece[:x] - 1)).each do |x_cordinate|
        (position_y..(piece[:y] - 1)).each do |y_cordinate|
          temp_piece << current_map[y_cordinate][x_cordinate]
          current_map[y_cordinate][x_cordinate] = "X"
        end
      end
      tomato_count = temp_piece.select{|spot| spot == "T"}.count
      mushroom_count = temp_piece.select{|spot| spot == "M"}.count
      x_count = temp_piece.select{|spot| spot == "X"}.count
      min_ingredient_count = temp_piece.select{|spot| spot == info.rare_ingredient}.count

      tomato_valid = tomato_count >= info.min_ingredients
      mushroom_valid = mushroom_count >= info.min_ingredients
      no_overlaping = x_count == 0

      if tomato_valid && mushroom_valid && temp_piece.count <= 6 && no_overlaping
        current_map.each do |level|
          puts level.inspect
        end
        decision = {piece: piece, placement: {x: position_x, y: position_y}}
        results << self.new(decision, nil, current_map, info, min_ingredient_count)
      end
    end

    return results
  end

  def explore
    results = []
    map_explored = false
    while(self.map[info.marker[:y]][info.marker[:x]] == "X" && map_explored == false) do
      if info.marker[:x] == (info.columns - 1) && info.marker[:y] == (info.rows - 1)
        info.marker[:x] = 0
        info.marker[:y] = 0
        map_explored == true
      elsif info.marker[:x] == (info.columns - 1)
        info.marker[:x] = 0
        info.marker[:y] = info.marker[:y] + 1
      else
        info.marker[:x] += 1
      end
    end
    return [] if map_explored == true
    position_x = info.marker[:x]
    position_y = info.marker[:y]

    self.info.pieces.each do |piece|
      current_map = self.map.map(&:clone)
      temp_piece = []
      next if (position_x + (piece[:x] - 1)) >= self.info.columns
      (position_x..(position_x + (piece[:x] - 1))).each do |x_cordinate|
        next if (position_y + (piece[:y] - 1)) >= self.info.rows
        (position_y..(position_y + (piece[:y] - 1))).each do |y_cordinate|
          temp_piece << current_map[y_cordinate][x_cordinate]
          current_map[y_cordinate][x_cordinate] = "X"
        end
      end
      tomato_count = temp_piece.select{|spot| spot == "T"}.count
      mushroom_count = temp_piece.select{|spot| spot == "M"}.count
      x_count = temp_piece.select{|spot| spot == "X"}.count
      min_ingredient_count = temp_piece.select{|spot| spot == info.rare_ingredient}.count

      tomato_valid = tomato_count >= info.min_ingredients
      mushroom_valid = mushroom_count >= info.min_ingredients
      no_overlaping = x_count == 0

      if tomato_valid && mushroom_valid && temp_piece.count <= info.max_slice_size && no_overlaping
        current_map.each do |level|
          puts level.inspect
        end
        puts ""
        decision = {piece: piece, placement: {x: position_x, y: position_y}}
        results << Node.new(decision, self, current_map, self.info, min_ingredient_count)
      end
    end

    return results
  end
end

class Info
  def initialize
    @rows = @columns = @min_ingredients = @max_slice_size = @tomato_count = @mushroom_count = @size = 0
    @pieces = []
  end

  attr_accessor :rows, :columns, :min_ingredients, :max_slice_size, :tomato_count, :mushroom_count, :map, :size, :pieces, :marker, :rare_ingredient
end

if ARGV[0].empty? || !File.exists?(ARGV[0])
  puts 'Please supply a valid file as an arguement.'
  exit
end

info = Info.new

file = File.open(ARGV[0])

index = 0
file.each_line do |line|
  if index > 0
    info.map[index - 1] = []
    line.each_char do |char|
      unless char == "\n"
        info.map[index - 1] << char
        info.tomato_count += 1 if char == 'T'
        info.mushroom_count += 1 if char == 'M'
      end
    end
  else
    split_first_line = line.split(' ')

    info.rows = split_first_line[0].to_i
    info.columns = split_first_line[1].to_i
    info.min_ingredients= split_first_line[2].to_i
    info.max_slice_size = split_first_line[3].to_i
    info.map = Array.new
  end

  index +=1
end
info.rare_ingredient = info.tomato_count > info.mushroom_count ? "M" : "T"
info.size = info.rows * info.columns
info.marker = {x: 0, y:0}
puts "#{info.min_ingredients} T & #{info.min_ingredients} M"
puts "min_ingredients per slice = #{info.min_ingredients * 2}"

puts "max_slice_size = #{info.max_slice_size}"

max_possible_slices = info.size.to_f / info.max_slice_size.to_f

puts "max largest possible slices per slice max size = #{max_possible_slices}"

puts "size = #{info.size}"
puts "max possible slices per lowest ingredient =  #{[info.tomato_count , info.mushroom_count].min.to_f / info.min_ingredients.to_f}"
puts "Average segements per slice = #{info.size / ([info.tomato_count , info.mushroom_count].min.to_f / info.min_ingredients.to_f)}"

def divisors_of(num)
  (1..num)
end

divisors = divisors_of(info.max_slice_size)

divisors.each do |divisor_x|
  divisors.each do |divisor_y|
    next if divisor_x * divisor_y > info.max_slice_size
    next if divisor_x * divisor_y < (info.min_ingredients * 2)
    next if divisor_x > info.columns
    next if divisor_y > info.rows
    info.pieces << {x: divisor_x, y: divisor_y}
  end
end

open_set = Hash.new
closed_set = []
itteration = 0
results = Node.explore(info.pieces, info.map, info)
puts ""
puts "--- First Exploration ---"
puts ""
itteration += 1
highest_weight = 0
count = 0
$found_solution = false

while($found_solution == false) do
  if !results.empty?
    results.each do |node|
      open_set[node.weight] = [] unless open_set[node.weight].is_a? Array
      open_set[node.weight] << node
      highest_weight = node.weight if node.weight > highest_weight
    end
  end

  current_set = open_set[highest_weight] || []

  while(current_set.empty?) do
    raise if highest_weight < 0
    highest_weight = (highest_weight.to_f - 0.1).round(2)
    current_set = open_set[highest_weight] || []
  end

  current_node = current_set.pop
  results = current_node.explore
  count += 1
  puts ""
  puts "--- Next Exploration ---"
  puts ""
  closed_set << current_node
end

