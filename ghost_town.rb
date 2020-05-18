require_relative 'tactic'

class GhostTown < Tactic
  def title
    '銀貨・ゴーストタウンで4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = SILVER
        end
      end
    end
  end

  def split_to_hands(deck)
    [deck[0...6], deck[6...11]]
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false)
    }
  end
end

GhostTown.new.report
