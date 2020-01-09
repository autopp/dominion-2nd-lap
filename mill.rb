require_relative 'tactic'

class Mill < Tactic
  def split_to_hands(deck)
    case deck.find_index(ACTION)
    when 0...5
      [deck[0...6].sort!, deck[6...11].sort!]
    when 5...10
      [deck[0...5].sort!, deck[5...11].sort!]
    else
      [deck[0...5].sort!, deck[5...10].sort!]
    end
  end

  def simulate_turn(hand)
    coin = 0
    hand.each do |card|
      case card
      when :c
        coin += 1
      when :s
        coin += 2
      when :a
        coin += [hand.count(:e), 2].min
      end
    end
    { coin: coin }
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
end

class MillWithTrashingHovel < Mill
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
