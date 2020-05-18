require_relative 'tactic'

class Castle < Tactic
  include SimulateTurnWithBaseCoinOnly

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      **result_of_both_5(t3, t4)
    }
  end
end

class CastleAndSilver < Castle
  def title
    '銀貨・粗末な城納屋廃棄で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11, num_of_estate: 2) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = SILVER
        end
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
  def title
    '粗末な城・粗末な城納屋廃棄で4ターン目までに……'
  end

  def gen_decks
    (0...11).to_a.combination(2).map do |others|
      deck = Array.new(11) { COPPER }
      deck[others[0]] = ESTATE
      deck[others[1]] = ESTATE
      deck
    end
  end

  def topics
    topic_for_at_least_once_5
  end
end

CastleAndSilver.new.report
puts
DoubleCastle.new.report
