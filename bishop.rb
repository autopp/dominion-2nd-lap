require_relative 'tactic'

class BishopTactic < Tactic
  include GenDecksBySilverAndAction

  def simulate_turn(hand, **_opts)
    coin = 0
    trashing_estate = false
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER
        coin += 2
      end
    end

    if hand.member?(ACTION) && hand.member?(ESTATE)
      trashing_estate = true
      coin += 1
    end
    { coin: coin, trashing_estate: trashing_estate }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)
    {
      at_least_once_5: at_least_once_5?(t3, t4),
      at_least_once_6: at_least_once_6?(t3, t4),
      both_5: both_5?(t3, t4),
      trashing_estate: or_for(t3, t4, :trashing_estate),
      trashing_estate_at_least_once_5: or_for(t3, t4, :trashing_estate) && at_least_once_5?(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6(geq: false),
      **topic_for_both_5,
      **topic_for_trashing_estate,
      **topic_for_trashing_and_at_least_once_5
    }
  end
end

BishopTactic.new.report
