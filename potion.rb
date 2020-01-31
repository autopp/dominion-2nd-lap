require_relative 'tactic'

class Potion < Tactic
  POTION = :potion

  def gen_decks
    raise NotImplementedError
  end

  def simulate_turn(hand)
    { coin: sum_of_coin(hand), potion: hand.include?(POTION) }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      potion_2: with_potion?(t3, t4, 2),
      potion_2_and_at_least_once_5: with_potion?(t3, t4, 2) && at_least_once_5?(t3, t4),
      potion_3: with_potion?(t3, t4, 3),
      potion_3_and_at_least_once_5: with_potion?(t3, t4, 3) && at_least_once_5?(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      potion_2: '2金 + ポーションを出せる確率',
      potion_2_and_at_least_once_5: '2金 + ポーションと5金の両方を出せる確率',
      potion_3: '3金 + ポーションを出せる確率',
      potion_3_and_at_least_once_5: '3金 + ポーションと5金の両方を出せる確率'
    }
  end

  private

  def with_potion?(t3, t4, coin)
    [t3, t4].any? do |t|
      t[:coin] >= coin && t[:potion]
    end
  end
end

class PotionWithSilver < Potion
  def title
    '銀貨・ポーションで4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(potion, silver)|
        factory.new_deck do |deck|
          deck[potion] = POTION
          deck[silver] = SILVER
        end
      end
    end
  end
end

class PotionWithDraw < Potion
  def title
    'ポーション・2ドローカード（堀など）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(potion, action)|
        factory.new_deck do |deck|
          deck[potion] = POTION
          deck[action] = ACTION
        end
      end
    end
  end

  def split_to_hands(deck)
    split_by_draw_action(deck, 2)
  end
end

PotionWithSilver.new.report
puts
PotionWithDraw.new.report
