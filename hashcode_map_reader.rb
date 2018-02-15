#!env ruby

require 'pry'

class Validator
  def initialize(rules)

  end

  def validate(piece)

  end
end

class Node
  attr_accessor :decision, :parent, :own_score, :score_total, :slice_tally, :weight

  def initialize(decision, parent) #{piece: {x: 1, y, 1}, placement: {x: 1, y: 1}}
    @decision = decision
    @parent = parent
    @own_score = decision[:x] * decision[:y] #number of segements in decision
    @score_total = @parent.score_tally + @own_score
    @slice_tally = @parent.slice_tally + 1
    @weight = @score_total / slice_tally
  end

  def explore
    result = []

    return results
  end
end

class Info
  def initialize
    @rows = @columns = @min_ingredients = @max_slice_size = @tomato_count = @mushroom_count = @size = 0
    @pieces = []
  end

  attr_accessor :rows, :columns, :min_ingredients, :max_slice_size, :tomato_count, :mushroom_count, :map, :size, :pieces
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

info.size = info.rows * info.columns

puts "#{info.min_ingredients} T & #{info.min_ingredients} M"
puts "min_ingredients per ingredient = #{info.min_ingredients * 2}"

puts "max_slice_size = #{info.max_slice_size}"

max_possible_slices = info.size.to_f / info.max_slice_size.to_f

puts "max largest possible slices per slice max size = #{max_possible_slices}"

puts "size = #{info.size}"
puts "max possible slices per lowest ingredient =  #{[info.tomato_count , info.mushroom_count].min.to_f / info.min_ingredients.to_f}"
puts "Average segements per slice = #{info.size / ([info.tomato_count , info.mushroom_count].min.to_f / info.min_ingredients.to_f)}"

def divisors_of(num)
  (1..num).select{|n|num % n == 0}
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

puts info.pieces

open_set = {}
closed_set = []


