require_relative 'tactic'

class Potion < Tactic
  POTION = :potion

  def gen_decks
    raise NotImplementedError
  end

  def simulate_turn(hand)
    coin = 0
    potion = false
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER
        coin += 2
      when POTION
        potion = true
      end
    end

    { coin: coin, potion: potion }
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
    case deck.find_index(ACTION)
    when 0...5
      [deck[0...7].sort!, deck[7...12].sort!]
    when 5...10
      [deck[0...5].sort!, deck[5...12].sort!]
    else
      [deck[0...5].sort!, deck[5...10].sort!]
    end
  end
end

PotionWithSilver.new.report
puts
PotionWithDraw.new.report
