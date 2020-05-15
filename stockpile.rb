require_relative 'tactic'

class Stockpile < Tactic
  def title
    'Stockpile・Stockpile で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.combination(2).map do |others|
        factory.new_deck do |deck|
          deck[others[0]] = GOLD
          deck[others[1]] = GOLD
        end
      end
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
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8, 9),
      **result_of_both_5(t3, t4),
      **result_of_both_and_at_least_once(t3, t4, 5, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8),
      **topic_for_at_least_once(9, geq: false),
      **topic_for_both_5,
      **topic_for_both_and_at_least_once(5, 6)
    }
  end
end

Stockpile.new.report
