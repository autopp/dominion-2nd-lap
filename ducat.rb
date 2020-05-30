require_relative 'tactic'

class Ducat < Tactic
  DUCAT = :ducat

  def simulate_turn(hand, coffer:, use_all_coffers:)
    coin = sum_of_coin(hand)
    coffer += hand.count(DUCAT)
    used_coffer = if use_all_coffers
      coffer
    else
      coin < 5 && coin + coffer >= 5 ? 5 - coin : 0
    end

    { coin: coin + used_coffer, coffer: coffer - used_coffer }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3, coffer: 0, use_all_coffers: false)
    t4 = simulate_turn(hand4, coffer: t3[:coffer], use_all_coffers: true)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      **topic_for_both_5
    }
  end
end

class DucatWithSilver < Ducat
  def title
    '銀貨・ドゥカート金貨（銅貨廃棄）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11) do |factory, other_indices|
      other_indices.permutation(2).map do |others|
        factory.new_deck do |deck|
          deck[others[0]] = SILVER
          deck[others[1]] = DUCAT
        end
      end
    end
  end
end

class DoubleDucat < Ducat
  def title
    'ドゥカート金貨・ドゥカート金貨（銅貨2枚廃棄）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(10) do |factory, other_indices|
      other_indices.combination(2).map do |others|
        factory.new_deck do |deck|
          deck[others[0]] = DUCAT
          deck[others[1]] = DUCAT
        end
      end
    end
  end
end

DucatWithSilver.new.report
puts
DoubleDucat.new.report
