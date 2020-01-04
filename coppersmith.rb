require_relative 'tactic'

class Coppersmith < Tactic
  include GenDecksWithSilverAndAction

  def simulate_turn(hand, **_opts)
    coin = 0
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER
        coin += 2
      when ACTION
        coin += hand.count(COPPER)
      end
    end
    { coin: coin }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4),
      **result_of_at_least_once_7(t3, t4),
      **result_of_at_least_once(t3, t4, 8),
      **result_of_both_5(t3, t4),
      **result_of_both_and_at_least_once(t3, t4, 5, 6),
      **result_of_both(t3, t4, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8, geq: false),
      **topic_for_both_5,
      **topic_for_both_and_at_least_once(5, 6, geq: false),
      **topic_for_both(6, geq: false)
    }
  end
end

Coppersmith.new.report
