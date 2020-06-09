require 'logger'

# Adds log functionality
module Loggable
  class << self
    attr_accessor :logger
  end
end

Loggable.logger = Logger.new(STDOUT)
Loggable.logger.formatter = proc { |severity, _, _, msg|
  "#{severity}\t#{msg}\n"
}
