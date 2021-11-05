require_relative 'tactic'

class BountyHunter < Tactic
  def simulate_turn(hand)
    coin = sum_of_coin(hand)

    if hand.member?(ACTION)
      if hand.member?(ESTATE)
        coin += 3
        trashed = ESTATE
      else
        coin += 2
        trashed = COPPER
      end
    end

    { coin: coin, trashing_estate: trashed == ESTATE }
  end

  def simulate(deck)
    t3, t4 = deck.map { simulate_turn(_1) }

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7),
      **result_of_both_5(t3, t4),
      **result_of_both_and_at_least_once(t3, t4, 5, 6),
      **result_of_both(t3, t4, 6),
      **result_of_trashing_estate(t3, t4),
      **result_of_trashing_estate_and_at_least_once(t3, t4, 6)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7(geq: false),
      **topic_for_both_5,
      **topic_for_both_and_at_least_once(5, 6),
      **topic_for_both(6, geq: false),
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once(6)
    }.transform_values do |v|
      v.sub('廃棄', ' Exile ')
    end
  end
end

class BountyHunterWithSilver < BountyHunter
  def title
    '銀貨・Bounty Hunter で4ターン目までに……'
  end

  include GenDecksWithSilverAndAction
end

class BountyHunterWithCopper < BountyHunter
  def title
    '銅貨（あるいは農民など）・Bounty Hunter で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.map do |action|
        factory.new_deck do |deck|
          deck[action] = ACTION
        end
      end
    end
  end
end

class BountyHunterOnly < BountyHunter
  def title
    'Bounty Hunter・パス（あるいは騎士見習いなど）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(11) do |factory, other_indices|
      other_indices.map do |action|
        factory.new_deck do |deck|
          deck[action] = ACTION
        end
      end
    end
  end
end

class BountyHunterWithCurse < BountyHunter
  def title
    '賞金稼ぎ・呪い（あるいは工房など）で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 4) do |factory, other_indices|
      other_indices.map do |action|
        factory.new_deck do |deck|
          deck[action] = ACTION
        end
      end
    end
  end
end

BountyHunterWithSilver.new.report
puts
BountyHunterWithCopper.new.report
puts
BountyHunterOnly.new.report
puts
BountyHunterWithCurse.new.report
