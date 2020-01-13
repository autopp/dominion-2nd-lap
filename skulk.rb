require_relative 'tactic'

class Skulk < Tactic
  GOLD = :gold

  def gen_decks
    with_combination_of_estates(13, num_of_estate: 4) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, gold)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[gold] = GOLD
        end
      end
    end
  end

  def simulate_turn(hand, **_opts)
    { coin: sum_of_coin(hand, GOLD => -> { 3 }) }
  end

  def simulate(deck)
    t3, t4 = deck.map(&method(:simulate_turn))

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8, geq: false),
      **topic_for_both_5
    }
  end
end

Skulk.new.report
