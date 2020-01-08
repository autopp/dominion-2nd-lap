require_relative 'tactic'

class Lookout < Tactic
  include GenDecksWithSilverAndAction

  def split_to_hands(deck)
    deck
  end

  def patterns_of_deck
    [
      { factor: 5, opts: { look_bought: false } },
      { factor: 1, opts: { look_bought: true } }
    ]
  end

  def simulate_turn(deck)
    coin = 0
    trash = nil
    discard = nil
    top = nil
    deck[0...5].each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER
        coin += 2
      when ACTION
        trash, discard, top = choose_trashing(deck[5...8])
      end
    end

    { coin: coin, trash: trash, discard: discard, top: top }
  end

  def simulate(deck, look_bought:)
    deck << look_bought ? SILVER : deck[0]
    t3 = simulate_turn(deck)
    rest = t3[:trash] ? [t3[:top], *deck[8...12]] : deck[6...13]
    t4 = simulate_turn(rest)

    trashing_estate = t3[:trash] == ESTATE || t4[:trash] == ESTATE
    at_least_once_5 = at_least_once_5?(t3, t4) # rubocop:disable Naming/VariableNumber
    cost5_in_next = at_least_once_5 && !t4[:trash]
    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      result_of_trashing_estate: trashing_estate,
      cost5_in_third_deck: at_least_once_5_and_third_deck,
      trashing_estate_and_at_least_once_5: trashing_estate && at_least_once_5,
      trashing_estate_and_cost5_in_third_deck: trashing_estate && cost5_in_next
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6(geq: false),
      **topic_for_trashing_estate,
      cost5_in_third_deck: '5金以上のカードが山札3周目に入る確率',
      **topic_for_trashing_estate_and_at_least_once_5,
      trashing_estate_and_cost5_in_third_deck: '屋敷を廃棄しつつ5金以上のカードが山札3周目に入る確率'
    }
  end
end
