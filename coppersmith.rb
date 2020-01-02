require_relative 'tactic'

class CoppersmithTactic < Tactic
  include GenDecksBySilverAndAction

  def simulate_turn(hand, **_opts)
    coin = 0
    hand.each do |card|
      case card
      when :c
        coin += 1
      when :s
        coin += 2
      when :a
        coin += hand.count(:c)
      end
    end
    { coin: coin }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      least_one_5: t3[:coin] >= 5 || t4[:coin] >= 5,
      least_one_6: t3[:coin] >= 6 || t4[:coin] >= 6,
      least_one_7: t3[:coin] >= 7 || t4[:coin] >= 7,
      least_one_8: t3[:coin] >= 8 || t4[:coin] >= 8,
      both_5: t3[:coin] >= 5 && t4[:coin] >= 5,
      both_5_6: (t3[:coin] == 5 && t4[:coin] >= 6) || (t3[:coin] >= 6 && t4[:coin] == 5) || (t3[:coin] >= 6 && t4[:coin] >= 6),
      both_6: t3[:coin] >= 6 && t4[:coin] >= 6
    }
  end

  def topics
    {
      least_one_5: '一度でも5金を出せる確率',
      least_one_6: '一度でも6金を出せる確率',
      least_one_7: '一度でも7金を出せる確率',
      least_one_8: '一度でも8金を出せる確率',
      both_5: '両方とも5金を出せる確率',
      both_5_6: '両方とも5金を出し、かつ一度でも6金を出せる確率',
      both_6: '両方とも6金を出せる確率'
    }
  end
end

CoppersmithTactic.new.report
