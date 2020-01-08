require_relative 'tactic'

class Magpie < Tactic
  MAGPIE = :magpie

  def gen_decks
    raise NotImplementedError
  end

  def split_to_hands(deck)
    case deck.find_index(MAGPIE)
    when 0...5
      treasure?(deck[6]) ? [deck[0...7], deck[7...12]] : [deck[0...6], deck[6...11]]
    when 5...10
      treasure?(deck[11]) ? [deck[0...5].sort!, deck[5...12]] : [deck[0...5].sort!, deck[5...11]]
    else
      [deck[0...5].sort!, deck[5...10].sort!]
    end
  end

  def simulate_turn(hand)
    coin = 0
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER, ACTION
        coin += 2
      end
    end

    { coin: coin, gained: hand.size == 6 }
  end

  def simulate(deck)
    hand3, hand4 = deck

    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    gained = any?(t3, t4, :gained)
    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4),
      **result_of_at_least_once_7(t3, t4),
      gained: gained,
      gained_and_at_least_once_5: gained && at_least_once_5?(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      gained: 'カササギを獲得する確率',
      gained_and_at_least_once_5: 'カササギを獲得しつつ一度でも5金以上が出る確率'
    }
  end

  private

  def treasure?(card)
    [SILVER, COPPER].include?(card)
  end
end

class MagpieWithSilver < Magpie
  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(magpie, silver)|
        factory.new_deck do |deck|
          deck[magpie] = MAGPIE
          deck[silver] = SILVER
        end
      end
    end
  end
end

class MagpieWithAction < Magpie
  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(magpie, action)|
        factory.new_deck do |deck|
          deck[magpie] = MAGPIE
          deck[action] = ACTION
        end
      end
    end
  end
end

MagpieWithSilver.new.report
puts
MagpieWithAction.new.report
