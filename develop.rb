require_relative 'tactic'

class Develop < Tactic
  include GenDecksWithSilverAndAction

  def title
    '銀貨・開発で屋敷は銀貨に変える場合、4ターン目までに……'
  end

  def simulate_turn(hand)
    coin = sum_of_coin(hand)
    trashing_estate = hand.member?(ACTION) && hand.member?(ESTATE)

    { coin: coin, trashing_estate: trashing_estate }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    hand4 = t3[:trashing_estate] ? [SILVER] + hand4.take(4) : hand4
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      **result_of_both_5(t3, t4),
      **result_of_trashing_estate(t3, t4),
      **result_of_trashing_estate_and_at_least_once_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_both_5,
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5
    }
  end
end

Develop.new.report
