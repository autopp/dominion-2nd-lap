require_relative 'tactic'

class FlagBearerAtFirstTurn < Tactic
  def gen_decks
    with_combination_of_estates(6, num_of_estate: 1) do |factory, other_indices|
      other_indices.map do |flag|
        [COPPER, COPPER, COPPER, ESTATE, ESTATE] + factory.new_deck do |deck|
          deck[flag] = SILVER
        end
      end
    end
  end

  def split_to_hands(deck)
    [deck[0...6].sort!, deck[6...11].sort!]
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand2, hand3 = deck
    t2 = simulate_turn(hand2)
    t3 = simulate_turn(hand3)

    {
      **result_of_at_least_onces(t2, t3, 5, 6),
      coin_5_at_t2: t2[:coin] >= 5
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      coin_5_at_t2: '2ターン目に5金以上が出る確率'
    }
  end
end

class FlagBearerAtSecondTurn < Tactic
  def gen_decks
    with_combination_of_estates(12, num_of_estate: 3) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, flag)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[flag] = SILVER
        end
      end
    end
  end

  def split_to_hands(_deck)
    raise NotImplementedError
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_at_least_once(t3, t4, 8),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8, geq: false),
      **topic_for_both_5
    }
  end
end

class FlagBearerAtSecondTurnWithFalg < FlagBearerAtSecondTurn
  def split_to_hands(deck)
    [deck[0...6].sort!, deck[6...12].sort!]
  end
end

class FlagBearerAtSecondTurnWithoutFalg < FlagBearerAtSecondTurn
  def split_to_hands(deck)
    [deck[0...6].sort!, deck[6...11].sort!]
  end
end

FlagBearerAtFirstTurn.new.report
puts
FlagBearerAtSecondTurnWithFalg.new.report
puts
FlagBearerAtSecondTurnWithoutFalg.new.report
