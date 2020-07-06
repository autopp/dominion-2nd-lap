require_relative 'tactic'

class Salvager < Tactic
  include GenDecksWithSilverAndAction

  def title
    '屋敷場かつ銀貨・引揚水夫で4ターン目までに……'
  end

  def simulate_turn(hand, **_opts)
    coin = sum_of_coin(hand)
    trashing_estate = false

    if hand.member?(ACTION) && hand.member?(ESTATE)
      trashing_estate = true
      coin += 2
    end
    { coin: coin, trashing_estate: trashing_estate }
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
      **topic_for_both_5,
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5
    }
  end
end

class SalvagerWithShelter < Salvager
  OVERGROWN_ESTATE = :overgrown_estate

  def title
    '避難所場かつ銀貨・引揚水夫で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12, num_of_estate: 2) do |factory, other_indices|
      other_indices.permutation(3).map do |(overgrown_estate, silver, action)|
        factory.new_deck do |deck|
          deck[overgrown_estate] = OVERGROWN_ESTATE
          deck[silver] = SILVER
          deck[action] = ACTION
        end
      end
    end
  end

  def split_to_hands(deck)
    top5 = deck[0...5].sort!
    return [deck[0...6].sort!, deck[6...11].sort!] if top5.member?(ACTION) && top5.member?(OVERGROWN_ESTATE)

    next5 = deck[5...10].sort!
    return [top5, deck[5...11].sort!] if next5.member?(ACTION) && next5.member?(OVERGROWN_ESTATE)

    [top5, next5]
  end

  def simulate_turn(hand, **_opts)
    coin = sum_of_coin(hand)
    trashing_estate = false

    if hand.member?(ACTION) && (hand.member?(ESTATE) || hand.member?(OVERGROWN_ESTATE))
      trashing_estate = true
      coin += 1
    end
    { coin: coin, trashing_estate: trashing_estate }
  end

  def topics
    super.transform_values! { _1.sub('屋敷', '避難所') }
  end
end

Salvager.new.report
puts
SalvagerWithShelter.new.report
