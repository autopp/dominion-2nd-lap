require_relative 'tactic'

class Transmogrify < Tactic
  include GenDecksWithSilverAndAction

  def title
    '銀・変容で屋敷は銀貨に変える場合、4ターン目までに……'
  end

  def simulate_turn(hand, reserved)
    coin = sum_of_coin(hand)
    trashing_estate = reserved && hand.include?(ESTATE)
    coin += 2 if trashing_estate

    { coin: coin, reserving: hand.include?(ACTION), trashing_estate: trashing_estate }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3, false)
    t4 = simulate_turn(hand4, t3[:reserving])

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

Transmogrify.new.report
