require_relative 'tactic'

class SilkMarchant < Tactic
  include GenDecksWithSilverAndAction

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

  def simulate_turn(hand)
    { coin: sum_of_coin(hand), hand: hand.size }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
      free_choice: t3[:hand] == 7 && t3[:coin] > 4
    }
  end

  def topics
    {
      at_least_once_5: '一度でも6金を出せる確率',
      at_least_once_6: '一度でも7金を出せる確率',
      at_least_once_7: '一度でも8金を出せる確率',
      **topic_for_both_5(geq: false),
      free_choice: '3Tの時点で5-5か6-4を自由に選べる確率'
    }
  end
end

SilkMarchant.new.report
