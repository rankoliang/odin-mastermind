# frozen_string_literal: true

# Hides guess input
require 'io/console'

# Any player playing the game
class Player
  attr_reader :name, :type

  def initialize(name = 'Anonymous', type = 'Player')
    self.name = name
    self.type = type
  end

  def self.computer(name = "Computer #{rand(1000)}", type = 'Computer')
    new(name, type)
  end

  protected

  attr_writer :name, :type
end

# Represents a code
module Code
  COLORS = Array(0..5)

  def self.matches(correct, attempt)
    correct.size - doesnt_match_pairs(correct, attempt).size
  end

  # Returns the number of groups that are in the wrong position
  def self.matches_except_position(correct, attempt)
    # tally of the count of each unmatched group
    unmatched_tally, attempt_tally = not_exact_match(correct, attempt).map(&:tally)

    # Returns 0 if all 4 matches were found
    return 0 unless attempt_tally

    # Unmatched adjusted by the attempts
    adjusted_unmatched = unmatched_tally.map do |color, count|
      not_in_attempt = count - (attempt_tally[color] || 0)
      [color, not_in_attempt.negative? ? 0 : not_in_attempt]
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
  # Manages player input
  module InputManager
    def code_input(code_length = 4)
      1.times do
        print "Enter a code (#{code_length} digit number with digits between #{Code::COLORS.min} - #{Code::COLORS.max}): "
        code = STDIN.noecho(&:gets).chomp
        if /^ *[#{Code::COLORS.min}-#{Code::COLORS.max}]{#{code_length}} *$/.match?(code)
          puts
          return code.split('').map(&:to_i)
        else
          puts 'Wrong format! Try again.'
          redo
        end
      end
    end
  end

  # Role is applied to a player temporarilly
  class Role
    include InputManager

    attr_reader :player

    def initialize(player = Player.new)
      self.player = player
    end

    def self.computer
      new(Player.computer)
    end

    private

    attr_writer :player
  end

  # Makes the initial code
  class CodeMaker < Role
    attr_reader :code

    def create_code(code_length = 4)
      # Skips if the CodeMaker already created their code
      return if code

      puts
      self.code =
        case player.type
        when 'Player'
          puts "#{player.name} needs to create their code."
          code_input(code_length)
        else
          puts "#{player.name} created their code."
          Code.random_code(code_length)
        end
    end

    def verify(attempt)
      feedback = {
        matches: Code.matches(code, attempt),
        matches_only_color: Code.matches_except_position(code, attempt)
      }
      if feedback[:matches] == code.size
        { success: true, code: code }
      else
        { success: false, feedback: feedback }
      end
    end

    private

    attr_writer :code
  end

  # Guesses the code
  class CodeBreaker < Role
    def attempt(code_length = 4)
      puts
      attempt =
        case player.type
        when 'Player'
          puts "#{player.name} needs to input an attempt."
          code_input(code_length)
        else
          Code.random_code(code_length)
        end
      puts "#{player.name} guessed #{attempt}"
      attempt
    end
  end
end

computer = Roles::CodeMaker.computer
computer2 = Roles::CodeBreaker.new

computer.create_code
# p computer.create_code

attempts = 0
loop do
  attempts += 1
  attempt = computer.verify(computer2.attempt)
  p attempt[:feedback].values unless attempt[:success]
  break if attempt[:success]
end
p computer.code
p attempts
# p computer.verify([0, 5, 5, 0])
