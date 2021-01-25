require_relative 'tactic'

class Cardinal < Tactic
  def split_to_hands(deck, **_opts)
    [deck[5...10], deck[10...12].sort!]
  end

  def simulate_turn(hand, attacked)
    coin_original = sum_of_coin(hand)
    coin = attacked ? sum_of_coin(discard(hand)) : coin_original
    { coin: coin, coin_original: coin_original }
  end

  def simulate(deck, attacked_t3:, attacked_t4:)
    hand4, bottom = deck
    exiled = if attacked_t3
      hand4[0...2].include?(SILVER)
    elsif attacked_t4
      bottom.include?(SILVER)
    else
      false
    end

    {
      exiled: exiled
    }
  end

  def topics
    {
      exiled: '相手のカードを追放できる確率'
    }
  end

  def patterns_of_deck
    [
      { factor: 2, opts: { attacked_t3: false, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: true, attacked_t4: false } },
      { factor: 5, opts: { attacked_t3: false, attacked_t4: true } }
    ]
  end
end

class CardinalFourThree < Cardinal
  def title
    '2人戦の先手番で自分が銀貨・枢機卿、相手が4-3の場合、4ターン目までに……'
  end

  include GenDecksWithDoubleSilver
end

class CardinalFiveTwo < Cardinal
  def title
    '2人戦の先手番で自分が銀貨・枢機卿、相手が5-2の場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 4) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = SILVER
        end
      end
    end
  end
end

CardinalFourThree.new.report
puts
CardinalFiveTwo.new.report
