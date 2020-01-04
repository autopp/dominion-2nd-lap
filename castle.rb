require_relative 'tactic'

class Castle < Tactic
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
    indices = (0...11).to_a
    indices.combination(2).flat_map do |estates|
      (indices - estates).map do |silver|
        deck = Array.new(11) { COPPER }
        deck[estates[0]] = ESTATE
        deck[estates[1]] = ESTATE
        deck[silver] = SILVER
        deck
      end
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
    (0...11).to_a.combination(2).map do |others|
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
