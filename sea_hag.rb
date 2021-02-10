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

  def simulate_turn(hand, attacked:)
    coin_original = sum_of_coin(hand)
    coin = attacked ? sum_of_coin(hand.drop(1)) : coin_original

    { coin: coin, coin_original: coin_original }
  end

  def simulate(deck, attacked_t3:, attacked_t4:)
    action_pos = deck.find_index(ACTION)

    h3_original, h4_original = case action_pos
    when 0...5
      [deck[0...7], deck[7...12]]
    when 5...10
      [deck[0...5], deck[5...12]]
    else
      [deck[0...5], deck[5...10]]
    end

    attacked_deck = deck.dup
    h3, h4 = if attacked_t3
      attacked_deck[5] = ESTATE
      case action_pos
      when 0...5
        [attacked_deck[0...7], attacked_deck[7...12]]
      when 6...10
        [attacked_deck[0...5], attacked_deck[5...12]]
      else
        [attacked_deck[0...5], attacked_deck[5...10]]
      end
    elsif attacked_t4
      case action_pos
      when 0...5
        [attacked_deck[0...7], attacked_deck[7...12]]
      when 5...10
        attacked_deck[10] = ESTATE
        [attacked_deck[0...5], attacked_deck[5...12]]
      else
        [h3_original, h4_original]
      end
    else
      [h3_original, h4_original]
    end

    t3 = { coin: sum_of_coin(h3), coin_original: sum_of_coin(h3_original) }
    t4 = { coin: sum_of_coin(h4), coin_original: sum_of_coin(h4_original) }

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
