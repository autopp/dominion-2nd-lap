require_relative 'tactic'

class Militia < Tactic
  include GenDecksWithDoubleSilver

  def patterns_of_deck
    raise NotImplementedError
  end

  def simulate_turn(hand, attacked)
    coin_original = sum_of_coin(hand)
    coin = attacked ? sum_of_coin(discard(hand)) : coin_original
    { coin: coin, coin_original: coin_original }
  end

  def simulate(deck, attacked_t3:, attacked_t4:)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3, attacked_t3)
    t4 = simulate_turn(hand4, attacked_t4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
      **result_of_lost(t4, t4, 5),
      **result_of_lost(t4, t4, 6)
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

  def sum_of_coin(hand)
    hand.sum do |card|
      case card
      when COPPER
        1
      when SILVER
        2
      else
        0
      end
    end
  end

  def discard(hand)
    hand.sort_by do |card|
      case card
      when COPPER
        1
      when SILVER
        2
      else
        0
      end
    end

    hand.reverse.take(3)
  end

  def result_of_lost(t3, t4, coin)
    losted = (t3[:coin_original] >= coin && t3[:coin] < coin) || (t4[:coin_original] >= coin && t4[:coin] < coin)
    { "lost_#{coin}": losted }
  end
end

class MilitiaFirstPlayer < Militia
  def title
    '2人戦の先手番で自分も相手も銀貨・民兵の場合、4ターン目までに……'
  end

  def patterns_of_deck
    [
      { factor: 7, opts: { attacked_t3: false, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: false, attacked_t4: true } }
    ]
  end
end

class MilitiaSecondPlayer < Militia
  def title
    '2人戦の後手番で自分も相手も銀貨・民兵の場合、4ターン目までに……'
  end

  def patterns_of_deck
    [
      { factor: 2, opts: { attacked_t3: false, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: true, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: false, attacked_t4: true } }
    ]
  end
end

MilitiaFirstPlayer.new.report
puts
MilitiaSecondPlayer.new.report
