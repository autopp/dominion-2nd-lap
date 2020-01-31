require_relative 'tactic'

class Silvers < Tactic
  def gen_decks
    NotImplementedError
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    t3, t4 = deck.map(&method(:simulate_turn))

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8),
      **result_of_both_5(t3, t4),
      **result_of_both_and_at_least_once(t3, t4, 5, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once(8, geq: false),
      **topic_for_both_5,
      **topic_for_both_and_at_least_once(5, 6)
    }
  end
end

class TripleSilvers < Silvers
  def title
    '銀貨・銀貨・銀貨で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(13) do |factory, other_indices|
      other_indices.combination(3).map do |(s1, s2, s3)|
        factory.new_deck do |deck|
          deck[s1] = SILVER
          deck[s2] = SILVER
          deck[s3] = SILVER
        end
      end
    end
  end
end

class DoubleSilversWithDraw < Silvers
  def gen_decks
    with_combination_of_estates(13) do |factory, other_indices|
      other_indices.combination(2).flat_map do |silvers|
        (other_indices - silvers).map do |action|
          factory.new_deck do |deck|
            deck[silvers[0]] = SILVER
            deck[silvers[1]] = SILVER
            deck[action] = ACTION
          end
        end
      end
    end
  end
end

class DoubleSilversWithTwoDraw < DoubleSilversWithDraw
  def title
    '銀貨・銀貨・2ドローカード（堀など）で4ターン目までに……'
  end

  def split_to_hands(deck)
    split_by_draw_action(deck, 2)
  end
end

class DoubleSilversWithThreeDraw < DoubleSilversWithDraw
  def title
    '銀貨・銀貨・3ドローカード（鍛冶屋など）で4ターン目までに……'
  end

  def split_to_hands(deck)
    split_by_draw_action(deck, 3)
  end

  def topics
    topics = super
    topics[:at_least_once_8] = '一度でも8金以上が出る確率'
    topics
  end
end

TripleSilvers.new.report
puts
DoubleSilversWithTwoDraw.new.report
puts
DoubleSilversWithThreeDraw.new.report
