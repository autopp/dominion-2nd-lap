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
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)
    {
      least_one_5: calc_least_one_5(t3, t4),
      least_one_6: calc_least_one_6(t3, t4),
      both_5: calc_both_5(t3, t4),
      trashed_estate: or_for(t3, t4, :trashed_estate),
      trashed_estate_least_one_5: or_for(t3, t4, :trashed_estate) && calc_least_one_5(t3, t4)
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
