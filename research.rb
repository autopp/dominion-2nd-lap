require_relative 'tactic'

class Research < Tactic
  include GenDecksWithSilverAndAction

  def title
    '銀貨・研究で4ターン目までに……'
  end

  def split_to_hands(deck)
    hand3 = deck[0...5].sort!
    hand4 = hand3.include?(ACTION) && hand3.include?(ESTATE) ? deck[5...12].sort! : deck[5...10].sort!
    [hand3, hand4]
  end

  def simulate_turn(hand)
    { coin: sum_of_coin(hand), trashing_estate: hand.include?(ACTION) && hand.include?(ESTATE) }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)
    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8),
      **result_of_trashing_estate(t3, t4),
      **result_of_trashing_estate_and_at_least_once_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once_8,
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5
    }
  end
end

Research.new.report
