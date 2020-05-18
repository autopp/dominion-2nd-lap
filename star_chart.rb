require_relative 'tactic'

class StarChart < Tactic
  def title
    '銀貨・星図で銀貨をトップに乗せた場合、4ターン目までに……'
  end

  def gen_decks
    (1...11).to_a.combination(3).map do |estates|
      deck = Array.new(11, COPPER)
      deck[0] = SILVER
      deck[estates[0]] = ESTATE
      deck[estates[1]] = ESTATE
      deck[estates[2]] = ESTATE
      deck
    end
  end

  include SimulateTurnWithBaseCoinOnly

  def simulate(deck)
    t3, t4 = deck.map(&method(:simulate_turn))

    {
      **result_of_at_least_onces(t3, t4, 5, 6),
      **result_of_both_5(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6(geq: false),
      **topic_for_both_5
    }
  end
end

StarChart.new.report
