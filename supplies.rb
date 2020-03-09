require_relative 'tactic'

class Supplies < Tactic
  SUPPLIES = :supplies

  def simulate_turn(hand)
    { coin: sum_of_coin(hand, SUPPLIES => -> { 1 }) }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      **topic_for_both_5(geq: false)
    }
  end
end

class SuppliesWithSilver < Supplies
  def title
    '銀貨・Supplies で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, supplies)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[supplies] = SUPPLIES
        end
      end
    end
  end

  def split_to_hands(deck)
    case deck.find_index(SUPPLIES)
    when 0...5
      [deck[0...5].sort!, deck[5...11].sort!]
    else
      [deck[0...5].sort!, deck[5...10].sort!]
    end
  end
end

class DoubleSupplies < Supplies
  def title
    'Supplies・Supplies で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(supplies1, supplies2)|
        factory.new_deck do |deck|
          deck[supplies1] = SUPPLIES
          deck[supplies2] = SUPPLIES
        end
      end
    end
  end

  def split_to_hands(deck)
    case deck[0...5].count(SUPPLIES)
    when 2
      [deck[0...5].sort!, deck[5...12].sort!]
    when 1
      [deck[0...5].sort!, deck[5...11].sort!]
    else
      [deck[0...5].sort!, deck[5...10].sort!]
    end
  end
end

SuppliesWithSilver.new.report
puts
DoubleSupplies.new.report
