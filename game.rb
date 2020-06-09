# Initializes a game with players passed through the init method or computers
class Game
  attr_reader :players

  def initialize(*players)
    players.push(Player.computer) while players.size < 2
    self.players = players
  end

  def play(max_attempts = 12)
    codemaker, codebreaker = assign_roles
    codemaker.create_code
    attempts = max_attempts
    while attempts.positive?
      Loggable.logger.info
      Loggable.logger.info "#{attempts} attempts left."
      attempts -= 1
      attempt = codemaker.verify(codebreaker.attempt(codemaker.all_feedback))
      Loggable.logger.debug attempt[:feedback].values unless attempt[:success]
      if attempt[:success]
        Loggable.logger.info 'Success!'
        break
      end
      Loggable.logger.info 'Failure!' if attempts.zero?
    end
    Loggable.logger.info "#{codemaker}'s code was #{codemaker.code}. #{codebreaker} took #{codebreaker.attempts.size} attempts."
    codebreaker.attempts.size
  end

  private

  def assign_roles
    randomized_players = players.shuffle!
    [Roles::CodeMaker.new(randomized_players[0]), Roles::CodeBreaker.new(randomized_players[1])]
  end
  attr_writer :players
end
