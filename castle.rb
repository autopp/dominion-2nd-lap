require_relative 'tactic'

class Castle < Tactic
  def split_to_hands(deck)
    [deck[0...5], deck[5...10]]
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4),
      **result_of_both_5(t3, t4)
    }
  end
end

class CastleAndSilver < Castle
  def gen_decks
    (0...11).to_a.permutation(3).map do |others|
      deck = Array.new(11) { COPPER }
      deck[others[0]] = ESTATE
      deck[others[1]] = ESTATE
      deck[others[2]] = SILVER
      deck
    end
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_both_5
    }
  end
end

class DoubleCastle < Castle
  def gen_decks
    (0...11).to_a.permutation(2).map do |others|
      deck = Array.new(11) { COPPER }
      deck[others[0]] = ESTATE
      deck[others[1]] = ESTATE
      deck
    end
  end

  def topics
    {
      **topic_for_at_least_once_5
    }
  end
end

CastleAndSilver.new.report
puts
DoubleCastle.new.report
