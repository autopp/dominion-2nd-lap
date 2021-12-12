require_relative 'tactic'

class SecretCave < Tactic
  def simulate_turn(hand, prev_duration)
    action_included = hand.include?(ACTION)
    coin = sum_of_coin(hand)
    coin += 3 if prev_duration
    { coin: coin, duration: action_included && coin < 6 }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3, false)
    t4 = simulate_turn(hand4, t3[:duration])

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once_8,
    }
  end
end

class SecretCaveWithSilver < SecretCave
  def title
    '銀貨・秘密の洞窟で4ターン目までに……'
  end

  include GenDecksWithSilverAndAction

  def split_to_hands(deck)
    case deck.find_index(ACTION)
    when 0...5
      [deck[0...6], deck[6...11]]
    when 5...10
      [deck[0...5], deck[5...11]]
    else
      [deck[0...5], deck[5...10]]
    end
  end
end

class DoubleSecretCave < SecretCave
  def title
    '秘密の洞窟・秘密の洞窟で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.combination(2).map do |(action1, action2)|
        factory.new_deck do |deck|
          deck[action1] = ACTION
          deck[action2] = ACTION
        end
      end
    end
  end

  def split_to_hands(deck)
    first = deck.find_index(ACTION)
    second = deck.find_index(ACTION)
    case first
    when 0...5
      case second
      when 1...6
        [deck[0...7], deck[7...12]]
      when 6...11
        [deck[0...6], deck[6...12]]
      else
        [deck[0...6], deck[6...11]]
      end
    when 5...10
      case second
      when 6...11
        [deck[0...5], deck[5...12]]
      else
        [deck[0...5], deck[5...11]]
      end
    else
      [deck[0...5], deck[5...10]]
    end
  end
end

SecretCaveWithSilver.new.report
puts
DoubleSecretCave.new.report
