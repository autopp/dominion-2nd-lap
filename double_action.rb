require_relative 'tactic'

class DoubleAction < Tactic
  DRAW_ACTION = :draw
  COIN_ACTION = :coin
  NECROPOLIS = :necropolis

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_both_5,
      both_action: 'アクションを両方プレイできる確率',
      doubled: 'アクションが事故る確率'
    }
  end
end

class DoubleCoinAction < DoubleAction
  def title
    '屋敷場で2金を出すターミナルアクション2枚を獲得した場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.combination(2).map do |(action1, action2)|
        factory.new_deck do |deck|
          deck[action1] = COIN_ACTION
          deck[action2] = COIN_ACTION
        end
      end
    end
  end

  def simulate_turn(hand)
    coin = hand.count(COPPER)
    necropolis = hand.include?(NECROPOLIS)
    coin_actions = hand.count(COIN_ACTION)
    doubled = coin_actions == 2 && !necropolis
    played = doubled ? 1 : coin_actions
    coin += played * 2

    { coin: coin, played: played, doubled: doubled }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      **result_of_both_5(t3, t4),
      both_action: t3[:played] + t4[:played] == 2,
      doubled: any?(t3, t4, :doubled)
    }
  end
end

class CoinAndDrawAction < DoubleAction
  def title
    '屋敷場で2金を出すターミナルアクション1枚と2ドローするターミナルアクション1枚を獲得した場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(coin, draw)|
        factory.new_deck do |deck|
          deck[coin] = COIN_ACTION
          deck[draw] = DRAW_ACTION
        end
      end
    end
  end

  def split_to_hands(deck)
    deck
  end

  def simulate_turn(hand, drawn)
    use_draw = use_draw?(hand)
    all_hand = use_draw ? hand + drawn : hand
    doubled = doubled?(hand, all_hand)

    coin = all_hand.count(COPPER)
    coin += 2 if all_hand.include?(COIN_ACTION) && (!doubled || !use_draw)
    played = doubled ? 1 : all_hand.count { |card| [COIN_ACTION, DRAW_ACTION].include?(card) }

    { coin: coin, drew: use_draw, played: played, doubled: doubled }
  end

  def simulate(deck)
    t3 = simulate_turn(deck[0...5], deck[5...7])
    hand4, drawn4 = t3[:drew] ? [deck[7...12], []] : [deck[5...10], deck[10...12]]
    t4 = simulate_turn(hand4, drawn4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      **result_of_both_5(t3, t4),
      both_action: t3[:played] + t4[:played] == 2,
      doubled: any?(t3, t4, :doubled)
    }
  end

  private

  def use_draw?(hand)
    hand.include?(DRAW_ACTION) && (!hand.include?(COIN_ACTION) || hand.include?(NECROPOLIS) || hand.count(COPPER) < 3)
  end

  def doubled?(hand, all_hand)
    !hand.include?(NECROPOLIS) && hand.include?(DRAW_ACTION) && all_hand.include?(COIN_ACTION)
  end
end

class DoubleCoinActionWithNecropolis < DoubleCoinAction
  def title
    '避難所場で2金を出すターミナルアクション2枚を獲得した場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 2) do |factory, other_indices|
      other_indices.permutation(3).map do |(necropolis, action1, action2)|
        factory.new_deck do |deck|
          deck[necropolis] = NECROPOLIS
          deck[action1] = COIN_ACTION
          deck[action2] = COIN_ACTION
        end
      end
    end
  end
end

class CoinAndDrawActionWithNecropolis < CoinAndDrawAction
  def title
    '避難所場で2金を出すターミナルアクション1枚と2ドローするターミナルアクション1枚を獲得した場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 2) do |factory, other_indices|
      other_indices.permutation(3).map do |(necropolis, coin, draw)|
        factory.new_deck do |deck|
          deck[necropolis] = NECROPOLIS
          deck[coin] = COIN_ACTION
          deck[draw] = DRAW_ACTION
        end
      end
    end
  end
end

DoubleCoinAction.new.report
puts
CoinAndDrawAction.new.report
puts
DoubleCoinActionWithNecropolis.new.report
puts
CoinAndDrawActionWithNecropolis.new.report
