require_relative 'tactic'

class BountyHunter < Tactic
  def title
    '銀貨・Bounty Hunter で4ターン目までに……'
  end

  include GenDecksWithSilverAndAction

  def simulate_turn(hand)
    coin = sum_of_coin(hand)

    if hand.member?(ACTION)
      if hand.member?(ESTATE)
        coin += 3
        trashed = ESTATE
      else
        coin += 2
        trashed = COPPER
      end
    end

    { coin: coin, trashing_estate: trashed == ESTATE }
  end

  def simulate(deck)
    t3, t4 = deck.map { simulate_turn(_1) }

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
      **result_of_both_and_at_least_once(t3, t4, 5, 6),
      **result_of_trashing_estate(t3, t4),
      **result_of_trashing_estate_and_at_least_once_5(t3, t4),
      **result_of_trashing_estate_and_at_least_once(t3, t4, 6),
      **result_of_trashing_estate_and_at_least_once(t3, t4, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      **topic_for_both_5,
      **topic_for_both_and_at_least_once(5, 6),
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5,
      **topic_for_trashing_estate_and_at_least_once(6)
    }
  end
end

BountyHunter.new.report
