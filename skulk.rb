require_relative 'tactic'

class Skulk < Tactic
  def simulate_turn(hand, **_opts)
    { coin: sum_of_coin(hand) }
  end

  def simulate(deck)
    t3, t4 = deck.map(&method(:simulate_turn))

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once_8,
      **topic_for_both_5
    }
  end
end

class SkulkWithSilver < Skulk
  def title
    '銀貨・暗躍者（+ 金貨）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(13, num_of_estate: 4) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, gold)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[gold] = GOLD
        end
      end
    end
  end
end

class SkulkWithDraw < Skulk
  def title
    '暗躍者（+ 金貨）・2ドローカード（堀など）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(13, num_of_estate: 4) do |factory, other_indices|
      other_indices.permutation(2).map do |(action, gold)|
        factory.new_deck do |deck|
          deck[action] = ACTION
          deck[gold] = GOLD
        end
      end
    end
  end

  def split_to_hands(deck)
    split_by_draw_action(deck, 2)
  end
end

class SkulkOnly < Skulk
  def title
    '暗躍者（+ 金貨）・パス（あるいは騎士見習いなど）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 4) do |factory, other_indices|
      other_indices.map do |gold|
        factory.new_deck do |deck|
          deck[gold] = GOLD
        end
      end
    end
  end
end

SkulkWithSilver.new.report
puts
SkulkWithDraw.new.report
puts
SkulkOnly.new.report
