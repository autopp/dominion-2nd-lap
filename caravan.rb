require_relative 'tactic'

class Caravan < Tactic
  include GenDecksWithSilverAndAction

  def title
    '銀貨・隊商で4ターン目までに……'
  end

  def split_to_hands(deck)
    case deck.find_index(ACTION)
    when 0...5
      [deck[0...6], deck[6...12]]
    when 5...10
      [deck[0...5], deck[5...11]]
    else
      [deck[0...5], deck[5...10]]
    end
  end

  def simulate_turn(hand)
    { coin: sum_of_coin(hand) }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false)
    }
  end
end

Caravan.new.report
