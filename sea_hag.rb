require_relative 'tactic'

class SeaHag < Tactic
  def split_to_hands(deck, **_opts)
    [*deck[0...5].sort!, *deck[5...12]]
  end

  def simulate_turn(hand, attacked:)
    coin_original = sum_of_coin(hand)
    coin = attacked ? sum_of_coin(hand.drop(1)) : coin_original

    { coin: coin, coin_original: coin_original }
  end

  def simulate(deck, attacked_t4:)
    t3 = simulate_turn(deck[0...5], attacked: false)
    t4 = simulate_turn(deck[5...10], attacked: attacked_t4)

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
      **topic_for_at_least_once_6(geq: false),
      lost_5: '5金以上の手札を5金未満にされる確率',
      lost_6: '6金以上の手札を6金未満にされる確率'
    }
  end

  def patterns_of_deck
    [
      { factor: 7, opts: { attacked_t4: false } },
      { factor: 5, opts: { attacked_t4: true } }
    ]
  end

  private

  def result_of_lost(t3, t4, coin)
    losted = (t3[:coin_original] >= coin && t3[:coin] < coin) || (t4[:coin_original] >= coin && t4[:coin] < coin)
    { "lost_#{coin}": losted }
  end
end

class SeaHagWithSeaHag < SeaHag
  include GenDecksWithSilverAndAction

  def title
    '2人戦の後手番で自分も相手も銀貨・海の妖婆の場合、4ターン目までに……'
  end
end

class SeaHagWithSilver < SeaHag
  include GenDecksWithDoubleSilver

  def title
    '2人戦の後手番で自分が銀貨・銀貨、相手が銀貨・海の妖婆の場合、4ターン目までに……'
  end
end

class SeaHagWithTwoDraw < SeaHag
  include GenDecksWithSilverAndAction

  def simulate_turn(deck, attacked)
    deck[5] = ESTATE if attacked
    hand_size = deck.find_index(ACTION)&.between?(0, 4) ? 7 : 5
    [sum_of_coin(deck.take(hand_size)), deck.drop(hand_size)]
  end

  def simulate(deck, attacked_t3:, attacked_t4:)
    deck_orig = deck.clone

    t3_coin_orig, rest = simulate_turn(deck_orig, false)
    t4_coin_orig, = simulate_turn(rest, false)

    deck_attacked = [*deck, ESTATE]
    t3_coin, rest = simulate_turn(deck_attacked, attacked_t3)
    t4_coin, = simulate_turn(rest, attacked_t4)

    t3 = { coin: t3_coin, coin_original: t3_coin_orig }
    t4 = { coin: t4_coin, coin_original: t4_coin_orig }

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
      **result_of_lost(t3, t4, 5),
      **result_of_lost(t3, t4, 6)
    }
  end
end

class SeaHagWithTwoDrawFirstPlayer < SeaHagWithTwoDraw
  def title
    '2人戦の先手番で自分が銀貨・2ドロー、相手が銀貨・海の妖婆の場合、4ターン目までに……'
  end

  def patterns_of_deck
    [
      { factor: 7, opts: { attacked_t3: false, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: false, attacked_t4: true } }
    ]
  end
end

class SeaHagWithTwoDrawSecondPlayer < SeaHagWithTwoDraw
  def title
    '2人戦の後手番で自分が銀貨・2ドロー、相手が銀貨・海の妖婆の場合、4ターン目までに……'
  end

  def patterns_of_deck
    [
      { factor: 2, opts: { attacked_t3: false, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: true, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: false, attacked_t4: true } }
    ]
  end
end

SeaHagWithSeaHag.new.report
puts
SeaHagWithSilver.new.report
puts
SeaHagWithTwoDrawFirstPlayer.new.report
puts
SeaHagWithTwoDrawSecondPlayer.new.report
