require_relative 'tactic'

class DoubleAction < Tactic
  DRAW_ACTION = :draw
  COIN_ACTION = :coin
  NECROPOLIS = :necropolis

  def gen_decks
    NotImplementedError
  end

  def split_to_hands(deck)
    deck
  end

  def simulate_turn(hand, drawn)
    coin = 0
    necropolis = false
    coin_action = 0
    draw_action = false
    played = 0
    doubled = false
    drew = false
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when NECROPOLIS
        necropolis = true
      when COIN_ACTION
        coin_action += 1
      when DRAW_ACTION
        draw_action = true
      end
    end

    if coin_action && draw_action
      if necropolis
        coin += 2
        played = 2
        drew = true
      else
        played = 1
        doubled = true
        if coin + 2 >= 5
          coin += 2
        else
          drew = true
        end
      end
    elsif coin_action == 1
      coin += 2
      played = 1
    elsif coin_action == 2
      if necropolis
        coin += 4
        played = 2
      else
        coin += 2
        played = 1
        doubled = true
      end
    elsif draw_action
      drew = true
      played = 1
    end

    if drew
      drawn.each do |card|
        case card
        when COPPER
          coin += 1
        when COIN_ACTION
          if necropolis
            coin += 2
            played = 2
          else
            doubled = true
          end
        end
      end
    end

    { coin: coin, drew: drew, played: played, doubled: doubled }
  end

  def simulate(deck)
    t3 = simulate_turn(deck[0...5], deck[5...7])
    hand4, drawn4 = t3[:drew] ? [deck[7...12], []] : [deck[5...10], deck[10...12]]
    t4 = simulate_turn(hand4, drawn4)

    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4),
      **result_of_both_5(t3, t4),
      both_action: t3[:played] + t4[:played] == 2,
      doubled: any?(t3, t4, :doubled)
    }
  end

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
  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(action1, action2)|
        factory.new_deck do |deck|
          deck[action1] = COIN_ACTION
          deck[action2] = COIN_ACTION
        end
      end
    end
  end
end

class CoinAndDrawAction < DoubleAction
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
end

class DoubleCoinActionWithNecropolis < DoubleAction
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

class CoinAndDrawActionWithNecropolis < DoubleAction
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
