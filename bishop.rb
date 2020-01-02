require_relative 'tactic'

class BishopTactic < Tactic
  include GenDecksBySilverAndAction

  def simulate_turn(hand, **_opts)
    coin = 0
    trashed_estate = false
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER
        coin += 2
      end
    end

    if hand.member?(ACTION) && hand.member?(ESTATE)
      trashed_estate = true
      coin += 1
    end
    { coin: coin, trashed_estate: trashed_estate }
  end

  def simulate(deck)
    t3, t4, = deck
    r3 = simulate_turn(t3)
    r4 = simulate_turn(t4)
    {
      least_one_5: r3[:coin] >= 5 || r4[:coin] >= 5,
      least_one_6: r3[:coin] >= 6 || r4[:coin] >= 6,
      both_5: r3[:coin] >= 5 && r4[:coin] >= 5,
      trashed_estate: r3[:trashed_estate] || r4[:trashed_estate],
      trashed_estate_least_one_5: (r3[:trashed_estate] || r4[:trashed_estate]) && (r3[:coin] >= 5 || r4[:coin] >= 5)
    }
  end

  def topics
    {
      least_one_5: '一度でも5金以上が出る確率',
      least_one_6: '一度でも6金が出る確率',
      both_5: '両方とも5金以上が出る確率',
      trashed_estate: '屋敷を廃棄できる確率',
      trashed_estate_least_one_5: '屋敷を廃棄しつつ1度でも5金以上が出る確率'
    }
  end
end

BishopTactic.new.report
