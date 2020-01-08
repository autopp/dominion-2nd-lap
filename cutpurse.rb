require_relative 'tactic'

class Cutpurse < Tactic
  include GenDecksWithDoubleSilver

  def patterns_of_deck
    raise NotImplementedError
  end

  def simulate_turn(hand, discarding:)
    coin_original = 0
    hand.each do |card|
      case card
      when COPPER
        coin_original += 1
      when SILVER
        coin_original += 2
      end
    end

    coin = discarding && hand.include?(:c) ? coin_original - 1 : coin_original
    { coin: coin, coin_original: coin_original }
  end

  def simulate(deck, discarding_t3:, discarding_t4:)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3, discarding: discarding_t3)
    t4 = simulate_turn(hand4, discarding: discarding_t4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
      **result_of_lost(t3, t4, 5),
      **result_of_lost(t3, t4, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      **topic_for_both_5,
      lost_5: '5金以上の手札を5金未満にされる確率',
      lost_6: '6金以上の手札を6金未満にされる確率'
    }
  end

  private

  def result_of_lost(t3, t4, coin)
    losted = (t3[:coin_original] >= coin && t3[:coin] < coin) || (t4[:coin_original] >= coin && t4[:coin] < coin)
    { "lost_#{coin}": losted }
  end
end

class CutpurseFirstPlayer < Cutpurse
  def patterns_of_deck
    [
      { factor: 7, opts: { discarding_t3: false, discarding_t4: false } },
      { factor: 5, opts: { discarding_t3: false, discarding_t4: true } }
    ]
  end
end

class CutpurseSecondPlayer < Cutpurse
  def patterns_of_deck
    [
      { factor: 2, opts: { discarding_t3: false, discarding_t4: false } },
      { factor: 5, opts: { discarding_t3: true, discarding_t4: false } },
      { factor: 5, opts: { discarding_t3: false, discarding_t4: true } }
    ]
  end
end

CutpurseFirstPlayer.new.report
puts
CutpurseSecondPlayer.new.report
