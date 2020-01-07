require_relative 'tactic'

class Enchantress < Tactic
  include GenDecksWithSilverAndAction

  def split_to_hands(deck)
    deck
  end

  def patterns_of_deck
    raise NotImplementedError
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck, enchantressed_t3:, enchantressed_t4:)
    hand3, hand4, duration, skip = case deck.find_index(ACTION)
    when 0...5
      enchantressed_t3 ? [deck[0...6], deck[6...11], false, true] : [deck[0...5], deck[5...12], true, false]
    when 5...10
      enchantressed_t4 ? [deck[0...5], deck[5...11], false, true] : [deck[0...5], deck[5...10], true, false]
    else
      [deck[0...5], deck[5...10], false, false]
    end

    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4),
      **result_of_at_least_once_7(t3, t4),
      duration: duration, skip: skip
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      duration: '女魔術師を持続させることができる確率',
      skip: '女魔術師がキャントリップになる確率'
    }
  end
end

class EnchantressOnlyMe < Enchantress
  def patterns_of_deck
    [
      { factor: 1, opts: { enchantressed_t3: false, enchantressed_t4: false } }
    ]
  end
end

class EnchantressFirstPlayer < Enchantress
  def patterns_of_deck
    [
      { factor: 7, opts: { enchantressed_t3: false, enchantressed_t4: false } },
      { factor: 5, opts: { enchantressed_t3: false, enchantressed_t4: true } }
    ]
  end
end

class EnchantressSecondPlayer < Enchantress
  def patterns_of_deck
    [
      { factor: 2, opts: { enchantressed_t3: false, enchantressed_t4: false } },
      { factor: 5, opts: { enchantressed_t3: true, enchantressed_t4: false } },
      { factor: 5, opts: { enchantressed_t3: false, enchantressed_t4: true } }
    ]
  end
end

EnchantressOnlyMe.new.report
puts
EnchantressFirstPlayer.new.report
puts
EnchantressSecondPlayer.new.report
