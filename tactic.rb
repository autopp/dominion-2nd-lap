class Tactic
  # @return [Symbol]
  COPPER = :c
  # @return [Symbol]
  SILVER = :s
  # @return [Symbol]
  ESTATE = :e
  # @return [Symbol]
  ACTION = :a

  # gen_decks returns deck of 2nd lap
  #
  # @return [Array<Symbol>]
  #
  def gen_decks
    raise NotImplementedError
  end

  # split_to_hands split deck to 2nd lap hands
  #
  # @param [Array<Symbol>] deck
  #
  # @return [Array(Array<Symbol>, Array<Symbol>, Array<Symbol>)]
  #
  def split_to_hands(deck)
    [deck[0...5], deck[5...10], deck[10...12]]
  end

  # simulate_turn simulates each turn and return results as Hash
  #
  # @param [Array<Symbol>] hand hand of this turn
  # @param [Hash] **opts
  #
  # @return [Hash] result
  #   * :coin [Integer] coin of this turn
  #
  def simulate_turn(hand, **opts)
    raise NotImplementedError
  end

  # simulate do 2nd lap of deck and return the result
  #
  # @param [Array(Array<Symbol>, Array<Symbol>, Array<Symbol>)] deck the deck of 2nd lap
  #
  # @return [Hash<Symbol, Boolean>]
  #
  def simulate(deck)
    raise NotImplementedError
  end

  # simulate_all returns all patterns of this storategy
  #
  # @return [Array<Hash<Symbol, Boolean>>]
  #
  def simulate_all
    decks = gen_decks
    decks.map { |deck| simulate(split_to_hands(deck)) }
  end

  # topics returns items of repot
  #
  # @return [Hash<Symbol, String>]
  #
  def topics
    raise NotImplementedError
  end

  def report
    results = simulate_all
    all = results.size
    topics.each do |topic, text|
      count = results.count { |r| r[topic] }
      puts "- #{text}: #{(count / all.to_f * 100).round(2)}%"
    end
  end

  # Helpers

  def or_for(t3, t4, key)
    t3[key] || t4[key]
  end

  def and_for(t3, t4, key)
    t3[key] && t4[key]
  end

  def least_one?(t3, t4, border)
    t3[:coin] >= border || t4[:coin] >= border
  end

  def least_one_5?(t3, t4)
    least_one?(t3, t4, 5)
  end

  def least_one_6?(t3, t4)
    least_one?(t3, t4, 6)
  end

  def least_one_7?(t3, t4)
    least_one?(t3, t4, 7)
  end

  def both?(t3, t4, border)
    t3[:coin] >= border && t4[:coin] >= border
  end

  def both_5?(t3, t4)
    both?(t3, t4, 5)
  end
end

module GenDecksBySilverAndAction
  def gen_decks
    (0...12).to_a.permutation(3 + 1 + 1).map do |indices|
      deck = Array.new(12) { Tactic::COPPER }
      e1, e2, e3, s, a = *indices
      deck[e1] = Tactic::ESTATE
      deck[e2] = Tactic::ESTATE
      deck[e3] = Tactic::ESTATE
      deck[s] = Tactic::SILVER
      deck[a] = Tactic::ACTION
      deck
    end
  end
end
