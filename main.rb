# frozen_string_literal: true

require_relative 'loggable'
require_relative 'player'
require_relative 'roles'
require_relative 'code'
require_relative 'game'

Loggable.logger.level = :warn

# game = Game.new
# game.play

# # Max attempts
# puts 50_00.times.map {
#   Game.new.play
# }.max

# Average attempts taken
puts 50_00.times.map {
  Game.new.play
}.sum/50_00.0

# # Win rate
# results = 50_00.times.map {
#   Game.new.play
# }.group_by {|x| x == 24}.map {|k, v| [k, v.size]}.to_h
# puts results[false].to_f / results.values.sum
