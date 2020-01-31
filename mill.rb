require_relative 'tactic'

class Mill < Tactic
  def split_to_hands(deck)
    split_by_draw_action(deck, 1)
  end

  def simulate_turn(hand)
    { coin: sum_of_coin(hand, ACTION => -> { [hand.count(ESTATE), 2].min }) }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t4, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6(geq: false),
      **topic_for_at_least_once_7(geq: false),
      **topic_for_both_5
    }
  end
end

class MillWithNormalStartHand < Mill
  include GenDecksWithSilverAndAction

  def title
    '銀貨・Mill で4ターン目までに……'
  end
end

class MillWithTrashingHovel < Mill
  def title
    '銀貨・Mill 納屋廃棄で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11, num_of_estate: 2) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, action)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[action] = ACTION
        end
      end
    end
  end
end

MillWithNormalStartHand.new.report
puts
MillWithTrashingHovel.new.report
