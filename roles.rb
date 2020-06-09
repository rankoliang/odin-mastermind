# Hides guess input
require 'io/console'

module Roles
  # Manages player input
  module InputManager
    def code_input(code_length = 4)
      1.times do
        Loggable.logger.info "Enter a code (#{code_length} digit number with digits between #{Code::COLORS.min} - #{Code::COLORS.max}): "
        code = STDIN.noecho(&:gets).chomp
        if /^ *[#{Code::COLORS.min}-#{Code::COLORS.max}]{#{code_length}} *$/.match?(code)
          return code.split('').map(&:to_i)
        else
          Loggable.logger.info "Wrong format! Try again. Your code was #{code}"
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

    def to_s
      player.name
    end

    private

    attr_writer :player
  end

  # Makes the initial code
  class CodeMaker < Role
    attr_reader :code, :all_feedback

    def initialize(player = Player.new)
      super
      self.all_feedback = []
    end

    def create_code(code_length = 4)
      # Skips if the CodeMaker already created their code
      return if code

      self.code =
        case player.type
        when 'Player'
          Loggable.logger.info "#{player.name} needs to create their code."
          code_input(code_length)
        else
          Loggable.logger.info "#{player.name} created their code."
          Code.random_code(code_length)
        end
    end

    def verify(attempt)
      feedback = {
        matches: Code.matches(code, attempt),
        matches_only_color: Code.matches_except_position(code, attempt)
      }
      all_feedback.push(feedback)
      if feedback[:matches] == code.size
        { success: true, code: code }
      else
        { success: false, feedback: feedback }
      end
    end

    private

    attr_writer :code, :all_feedback
  end

  # Guesses the code
  class CodeBreaker < Role
    attr_reader :attempts

    def initialize(player = Player.new)
      super
      self.attempts = []
      self.possible_values = []
      self.last_attempted_index = -1
      self.confidence_index = -1
      # free_indexes[0] = keeps track of indexes used for current values
      # free_indexes[1] = keeps track of which indexes are not taken
      self.trial_index = 0
    end

    def attempt(feedback = [], code_length = 4)
      attempt =
        case player.type
        when 'Player'
          # Player input
          Loggable.logger.info "#{player.name} needs to input an attempt."
          code_input(code_length)
        else
          # Computer AI
          populate_possible_values(feedback, code_length)
          code = computer_generate_code(feedback, code_length)
          Loggable.logger.debug "Possible values: #{possible_values}"
          code
        end
      attempts.push(attempt)
      Loggable.logger.info "#{player.name} guessed #{attempt}"
      attempt
    end

    private

    attr_writer :attempts
    attr_accessor :possible_values, :last_attempted_index, :fail_guess, :confidence_index, :trial_index, :code_permutations

    def populate_possible_values(feedback, code_length)
      return unless (feedback.last && possible_values.size < code_length) && confidence_index.negative?

      feedback.last.values.sum.times do
        possible_values.push(last_attempted_index)
      end
      # Sets a guess that is guaranteed to fail
      set_fail_guess if possible_values.size == code_length
    end

    def computer_generate_code(feedback, code_length)
      if possible_values.size == code_length || confidence_index.positive?
        permute_code(feedback, code_length)
        # possible_values.shuffle!
      elsif last_attempted_index < Code::COLORS.size - 1
        self.last_attempted_index += 1
        Array.new(code_length, Code::COLORS[last_attempted_index])
      else
        Code.random_code
      end
    end

    def set_fail_guess
      self.fail_guess = Code::COLORS.find { |x| !possible_values.include? x }
    end

    def permute_code(feedback, code_length)
      Loggable.logger.debug "confidence_index #{confidence_index}, Trial_index #{trial_index}"
      if confidence_index == -1
        possible_values.shuffle!
        self.confidence_index = 0
        attempt = Array.new(code_length, fail_guess)
        attempt[trial_index] = possible_values[confidence_index]
        self.confidence_index += 1
        attempt
      else
        last_attempt = attempts.last.clone
        if feedback.last[:matches] > trial_index
          possible_values.delete_at(possible_values.index(last_attempt[trial_index]))
          self.trial_index += 1
          self.confidence_index = 0
        end
        last_attempt[trial_index] = possible_values[confidence_index]
        self.confidence_index += 1
        last_attempt
      end
    end
  end
end
