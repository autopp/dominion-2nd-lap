require_relative 'tactic'

class CoppersmithTactic < Tactic
  include GenDecksBySilverAndAction

  def simulate_turn(hand, **_opts)
    coin = 0
    hand.each do |card|
      case card
      when :c
        coin += 1
      when :s
        coin += 2
      when :a
        coin += hand.count(:c)
      end
    end
    { coin: coin }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      at_least_once_5: at_least_once_5?(t3, t4),
      at_least_once_6: at_least_once_6?(t3, t4),
      at_least_once_7: at_least_once_7?(t3, t4),
      at_least_once_8: at_least_once?(t3, t4, 8),
      both_5: both_5?(t3, t4),
      both_5_6: both_5?(t3, t4) && at_least_once_6?(t3, t4),
      both_6: both?(t3, t4, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8, geq: false),
      **topic_for_both_5,
      both_5_6: '両方とも5金を出し、かつ一度でも6金を出せる確率',
      **topic_for_both(6, geq: false)
    }
  end
end

CoppersmithTactic.new.report
