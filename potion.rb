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
      potion_2: any_with_potion?(t3, t4, 2),
      potion_2_and_at_least_once_5: with_potion_and_5?(t3, t4, 2),
      potion_3: any_with_potion?(t3, t4, 3),
      potion_3_and_at_least_once_5: with_potion_and_5?(t3, t4, 3)
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

  def with_potion?(t, coin)
    t[:coin] >= coin && t[:potion]
  end

  def any_with_potion?(t3, t4, coin)
    [t3, t4].any? do |t|
      with_potion?(t, coin)
    end
  end

  def with_potion_and_5?(t3, t4, coin)
    [[t3, t4], [t4, t3]].any? do |(t1, t2)|
      t1[:coin] >= coin && t1[:potion] && t2[:coin] >= 5
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

class PotionWithStoreroom < Potion
  def title
    "ポーション・物置で3T目の物置は#{num_of_discard}枚捨てる場合、デッキ3周目までに……"
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
    split_by_draw_action(deck, num_of_discard)
  end

  def simulate_turn(hand)
    if hand.include?(ACTION)
      { coin: hand.count(COPPER) + hand.count(ESTATE), potion: hand.include?(POTION) }
    else
      { coin: sum_of_coin(hand), potion: hand.include?(POTION) }
    end
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)

    if hand3.size > 7
      {
        potion_2: with_potion?(t3, 2),
        potion_3: with_potion?(t3, 3)
      }
    else
      t4 = simulate_turn(hand4)

      {
        potion_2: any_with_potion?(t3, t4, 2),
        potion_3: any_with_potion?(t3, t4, 3)
      }
    end
  end

  def topics
    {
      potion_2: '2金 + ポーションを出せる確率',
      potion_3: '3金 + ポーションを出せる確率'
    }
  end
end

class PotionWithStoreroom2 < PotionWithStoreroom
  def num_of_discard
    2
  end
end

class PotionWithStoreroom3 < PotionWithStoreroom
  def num_of_discard
    3
  end
end

class PotionWithStoreroom4 < PotionWithStoreroom
  def num_of_discard
    4
  end
end

PotionWithSilver.new.report
puts
PotionWithDraw.new.report
puts
PotionWithStoreroom2.new.report
puts
PotionWithStoreroom3.new.report
puts
PotionWithStoreroom4.new.report
