require_relative 'tactic'

class FoolsGold < Tactic
  FOOLS_GOLD = :fools_gold

  def title
    '愚者の黄金・愚者の黄金で4ターン目までに……'
  end

  def gen_decks
    gen_decks_with_double(FOOLS_GOLD)
  end

  def simulate_turn(hand)
    coin = sum_of_coin(hand)
    coin += case hand.count(FOOLS_GOLD)
    when 1 then 1
    when 2 then 5
    else 0
    end

    { coin: coin }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_both_5,
    }
  end
end

FoolsGold.new.report
