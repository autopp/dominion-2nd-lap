require_relative 'tactic'

class Sacrifice < Tactic
  include GenDecksWithSilverAndAction

  def simulate_turn(hand)
    coin = sum_of_coin(hand)
    trashing_estate = false

    if hand.include?(ACTION)
      if hand.include?(ESTATE) && coin != 4
        trashing_estate = true
      else
        coin += 1
      end
    end

    { coin: coin, trashing_estate: trashing_estate }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
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
      **topic_for_at_least_once_6(geq: false),
      **topic_for_both_5(geq: false),
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5
    }
  end
end

Sacrifice.new.report
