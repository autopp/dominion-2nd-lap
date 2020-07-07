require_relative 'tactic'

class CursedGold < Tactic
  def title
    '呪われた金貨を一度も使わずに銀貨・銀貨で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 4) do |factory, other_indices|
      other_indices.permutation(2).map do |silver1, silver2|
        factory.new_deck do |deck|
          deck[silver1] = SILVER
          deck[silver2] = SILVER
        end
      end
    end
  end

  include SimulateTurnWithBaseCoinOnly

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_both_5(geq: false)
    }
  end
end

CursedGold.new.report
