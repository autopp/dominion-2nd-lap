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
    hand = deck[0...5]
    coin = sum_of_coin(hand)
    trash, discard, top = hand.include?(ACTION) ? choose_trashing(deck[5...8]) : [nil, nil, nil]

    { coin: coin, trash: trash, discard: discard, top: top }
  end

  def simulate(deck, look_bought:)
    deck << look_bought ? SILVER : deck[0]
    t3 = simulate_turn(deck)
    rest = t3[:trash] ? [t3[:top], *deck[8...12]] : deck[6...13]
    t4 = simulate_turn(rest)

    trashing_estate = t3[:trash] == ESTATE || t4[:trash] == ESTATE
    at_least_once_5 = at_least_once_5?(t3, t4) # rubocop:disable Naming/VariableNumber
    cost5_in_third_deck = at_least_once_5 && !t4[:trash]

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      trashing_estate: trashing_estate,
      cost5_in_third_deck: cost5_in_third_deck,
      trashing_estate_and_at_least_once_5: trashing_estate && at_least_once_5,
      trashing_estate_and_cost5_in_third_deck: trashing_estate && cost5_in_third_deck
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

  private

  def choose_trashing(cards)
    cards.sort_by do |card|
      case card
      when ESTATE
        0
      when COPPER
        1
      else
        2
      end
    end
  end
end

Lookout.new.report
