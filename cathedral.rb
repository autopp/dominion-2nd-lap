require_relative 'tactic'

class Cathedral < Tactic
  def simulate_turn(hand)
    coin = sum_of_coin(hand)

    if hand.member?(ESTATE)
      trashed = ESTATE
    else
      coin -= 1
      trashed = COPPER
    end

    { coin: coin, trashing_estate: trashed == ESTATE }
  end

  def simulate(deck)
    t3, t4 = deck.map { simulate_turn(_1) }

    {
      **result_of_at_least_onces(t3, t4, 5),
      trashed_all_estates: [t3, t4].all? { _1[:trashing_estate] }
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      trashed_all_estates: '両ターン共に屋敷を廃棄できる確率'
    }
  end
end

class CathedralSilver < Cathedral
  def title
    '大聖堂・銀貨で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(10, num_of_estate: 2) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = SILVER
        end
      end
    end
  end
end

class SilverCathedral < Cathedral
  def title
    '銀貨・大聖堂で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = SILVER
        end
      end
    end
  end
end

class CathedralGold < Cathedral
  def title
    '大聖堂・金貨（あるいは石切場など）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(10, num_of_estate: 2) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = GOLD
        end
      end
    end
  end
end

class GoldCathedral < Cathedral
  def title
    '金貨（あるいは石切り場など）・大聖堂で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11) do |factory, other_indices|
      other_indices.map do |silver|
        factory.new_deck do |deck|
          deck[silver] = GOLD
        end
      end
    end
  end
end

CathedralSilver.new.report
puts
SilverCathedral.new.report
puts
CathedralGold.new.report
puts
GoldCathedral.new.report
