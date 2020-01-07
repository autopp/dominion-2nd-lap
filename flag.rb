def calc(hand)
  coin = 0
  hand.each do |card|
    case card
    when :c
      coin += 1
    when :a, :s
      coin += 2
    when :g
      coin += 3
    end
  end
  { coin: coin }
end

decks = (1...11).to_a.permutation(3).map do |indices|
  deck = Array.new(11) { :c }
  e1, e2, e3 = *indices
  deck[0] = :s
  deck[e1] = :e
  deck[e2] = :e
  deck[e3] = :e
  deck
end

stats = decks.map do |deck|
  t3 = calc(deck[0...5])
  t4 = calc(deck[5...10])

  {
    at_least_once_5: t3[:coin] >= 5 || t4[:coin] >= 5,
    at_least_once_6: t3[:coin] >= 6 || t4[:coin] >= 6,
    both_5: t3[:coin] >= 5 && t4[:coin] >= 5
  }
end

texts = {
  at_least_once_5: '一度でも5金を出せる確率',
  at_least_once_6: '一度でも6金を出せる確率',
  both_5: '両方とも5金を出せる確率'
}

all = decks.size
texts.each do |k, text|
  count = stats.count { |stat| stat[k] }
  puts "- #{text}: #{(count / all.to_f * 100).round(2)}%"
end

require_relative 'tactic'

class FlagBearerAtFirstTurn < Tactic
  def gen_decks
    with_combination_of_estates(6, num_of_estate: 1) do |factory, other_indices|
      other_indices.map do |flag|
        [COPPER, COPPER, COPPER, ESTATE, ESTATE] + factory.new_deck do |deck|
          deck[flag] = SILVER
        end
      end
    end
  end

  def split_to_hands(deck)
    [deck[0...6].sort!, deck[6...11].sort!]
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand2, hand3 = deck
    t2 = simulate_turn(hand2)
    t3 = simulate_turn(hand3)

    {
      **result_of_at_least_once_5(t2, t3),
      **result_of_at_least_once_6(t2, t3),
      coin_5_at_t2: t2[:coin] >= 5
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      coin_5_at_t2: '2ターン目に5金以上が出る確率'
    }
  end
end

class FlagBearerAtSecondTurn < Tactic
  def gen_decks
    with_combination_of_estates(12, num_of_estate: 3) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, flag)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[flag] = SILVER
        end
      end
    end
  end

  def split_to_hands(_deck)
    raise NotImplementedError
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4),
      **result_of_at_least_once_7(t3, t4),
      **result_of_at_least_once(t3, t4, 8),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8, geq: false),
      **topic_for_both_5
    }
  end
end

class FlagBearerAtSecondTurnWithFalg < FlagBearerAtSecondTurn
  def split_to_hands(deck)
    [deck[0...6].sort!, deck[6...12].sort!]
  end
end

class FlagBearerAtSecondTurnWithoutFalg < FlagBearerAtSecondTurn
  def split_to_hands(deck)
    [deck[0...6].sort!, deck[6...11].sort!]
  end
end

FlagBearerAtFirstTurn.new.report
puts
FlagBearerAtSecondTurnWithFalg.new.report
puts
FlagBearerAtSecondTurnWithoutFalg.new.report
