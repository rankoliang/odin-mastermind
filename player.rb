# Any player playing the game
class Player
  attr_reader :name, :type

  def initialize(name = "Anonymous #{rand(1000)}", type = 'Player')
    self.name = name
    self.type = type
  end

  def self.computer(name = "Computer #{rand(1000)}", type = 'Computer')
    new(name, type)
  end

  def to_s
    name
  end

  protected

  attr_writer :name, :type
end
