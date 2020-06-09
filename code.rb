# Represents a code of 4 digits from 0 - 5 inclusive
module Code
  COLORS = Array(0..5)

  # Number of groups that correctly matched
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