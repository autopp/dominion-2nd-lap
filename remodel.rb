require_relative 'tactic'

class Remodel < Tactic
  REMODEL = :remodel

  def simulate_turn(hand)
    { coin: sum_of_coin(hand), trashing_estate: hand.member?(REMODEL) && hand.member?(ESTATE) }
  end

  def simulate(deck)
    hand3, hand4, = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)
    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      **result_of_both_5(t3, t4),
      **result_of_trashing_estate(t3, t4),
      **result_of_trashing_estate_and_at_least_once_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6(geq: false),
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5
    }
  end
end

class RemodelWithSilver < Remodel
  def title
    '銀貨・改築で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(silver, remodel)|
        factory.new_deck do |deck|
          deck[silver] = SILVER
          deck[remodel] = REMODEL
        end
      end
    end
  end
end

class RemodelWithDraw < Remodel
  def title
    '改築・アクション付き2ドロー（追従者など）で4ターン目までに……'
  end


  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |(action, remodel)|
        factory.new_deck do |deck|
          deck[action] = ACTION
          deck[remodel] = REMODEL
        end
      end
    end
  end

  def split_to_hands(deck)
    split_by_draw_action(deck, 2)
  end
end

RemodelWithSilver.new.report
puts
RemodelWithDraw.new.report
