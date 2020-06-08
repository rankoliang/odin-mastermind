# frozen_string_literal: true

srand 1231

# Any player playing the game
class Player
  attr_reader :name

  def initialize(name = 'Anonymous')
    self.name = name
  end

  protected

  attr_writer :name
end

# Represents a code
module Code
  COLORS = Array(0..6)

  def self.matches(correct, attempt)
    correct.size - doesnt_match_pairs(correct, attempt).size
  end

  # Returns the number of groups that are in the wrong position
  def self.matches_except_position(correct, attempt)
    # tally of the count of each unmatched group
    unmatched_tally, attempt_tally = not_exact_match(correct, attempt).map(&:tally)

    # Returns 0 if all 4 matches
    return 0 unless attempt_tally

    # Unmatched adjusted by the attempts
    adjusted_unmatched = unmatched_tally.map do |color, count|
      not_in_attempt = count - (attempt_tally[color] || 0)
      [color, not_in_attempt < 0 ? 0 : not_in_attempt]
    end.to_h.values.sum

    # Matches found
    unmatched_tally.values.sum - adjusted_unmatched
  end

  # returns all of the groups that don't match by position
  def self.not_exact_match(correct, attempt)
    doesnt_match_pairs(correct, attempt).transpose
  end

  def self.random_code(code_length = 4)
    Array.new(code_length) { Code::COLORS.sample }
  end

  def self.doesnt_match_pairs(correct, attempt)
    correct.zip(attempt).reject do |correct_color, attempted_color|
      correct_color == attempted_color
    end
  end
end

module Roles
  # Role is applied to a player temporarilly
  class Role
    attr_reader :name

    def initialize(player)
      self.name = player.name
    end

    private

    attr_writer :name
  end

  # Makes the initial code
  class CodeMaker < Role
    attr_reader :code

    def initialize(player)
      super
      create_code
    end

    def create_code(code_length = 4)
      self.code = Code.random_code(code_length)
    end

    def verify(attempt)
      feedback = {
        matches: Code.matches(code, attempt),
        matches_only_color: Code.matches_except_position(code, attempt)
      }
      if feedback[:matches] == code.size
        code
      else
        feedback.values
      end
    end

    private

    attr_writer :code
  end

  # Guesses the code
  class CodeBreaker < Role
    def attempt(code_length = 4)
      Code.random_code(code_length)
    end
  end
end

computer = Roles::CodeMaker.new(Player.new)
player = Roles::CodeBreaker.new(Player.new)

p computer.verify([0, 5, 5, 4])
