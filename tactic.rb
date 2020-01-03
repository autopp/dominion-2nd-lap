module CommonResults
  # predicate

  def any?(t3, t4, key)
    raise KeyError, "turn3 dose not contain #{key.inspect}" if !t3.include?(key)
    raise KeyError, "turn4 dose not contain #{key.inspect}" if !t4.include?(key)

    t3[key] || t4[key]
  end

  def all?(t3, t4, key)
    raise KeyError, "turn3 dose not contain #{key.inspect}" if !t3.include?(key)
    raise KeyError, "turn4 dose not contain #{key.inspect}" if !t4.include?(key)

    t3[key] && t4[key]
  end

  def at_least_once?(t3, t4, coin)
    raise KeyError, 'turn3 dose not contain :coin' if !t3.include?(:coin)
    raise KeyError, 'turn4 dose not contain :coin' if !t4.include?(:coin)

    t3[:coin] >= coin || t4[:coin] >= coin
  end

  def at_least_once_5?(t3, t4)
    at_least_once?(t3, t4, 5)
  end

  def at_least_once_6?(t3, t4)
    at_least_once?(t3, t4, 6)
  end

  def at_least_once_7?(t3, t4)
    at_least_once?(t3, t4, 7)
  end

  def both?(t3, t4, coin)
    t3[:coin] >= coin && t4[:coin] >= coin
  end

  def both_5?(t3, t4)
    both?(t3, t4, 5)
  end

  def trashing_estate?(t3, t4)
    any?(t3, t4, :trashing_estate)
  end

  # result_of_xxx

  def result_of_any(t3, t4, key)
    { key => any?(t3, t4, key) }
  end

  def result_of_all(t3, t4, key)
    { key => all?(t3, t4, key) }
  end

  def result_of_at_least_once(t3, t4, coin)
    { "at_least_once_#{coin}": at_least_once?(t3, t4, coin) }
  end

  def result_of_at_least_once_5(t3, t4)
    result_of_at_least_once(t3, t4, 5)
  end

  def result_of_at_least_once_6(t3, t4)
    result_of_at_least_once(t3, t4, 6)
  end

  def result_of_at_least_once_7(t3, t4)
    result_of_at_least_once(t3, t4, 7)
  end

  def result_of_both(t3, t4, coin)
    { "both_#{coin}": both?(t3, t4, coin) }
  end

  def result_of_both_5(t3, t4)
    result_of_both(t3, t4, 5)
  end

  def result_of_both_and_at_least_once(t3, t4, both_coin, at_least_once_coin)
    key = :"both_#{both_coin}_and_at_least_once_#{at_least_once_coin}"
    { key => both?(t3, t4, both_coin) && at_least_once?(t3, t4, at_least_once_coin) }
  end

  def result_of_trashing_estate(t3, t4)
    result_of_any(t3, t4, :trashing_estate)
  end

  def result_of_trashing_estate_and_at_least_once(t3, t4, coin)
    { "trashing_estate_and_at_least_once_#{coin}": trashing_estate?(t3, t4) && at_least_once?(t3, t4, coin) }
  end

  def result_of_trashing_estate_and_at_least_once_5(t3, t4)
    result_of_trashing_estate_and_at_least_once(t3, t4, 5)
  end
end

module CommonTopics
  def topic_for_at_least_once(coin, geq: true)
    { "at_least_once_#{coin}": "一度でも#{coin}金#{geq ? '以上' : ''}が出る確率" }
  end

  def topic_for_at_least_once_5(geq: true)
    topic_for_at_least_once(5, geq: geq)
  end

  def topic_for_at_least_once_6(geq: true)
    topic_for_at_least_once(6, geq: geq)
  end

  def topic_for_at_least_once_7(geq: true)
    topic_for_at_least_once(7, geq: geq)
  end

  def topic_for_both(coin, geq: true)
    { "both_#{coin}": "両ターン共に#{coin}金#{geq ? '以上' : ''}が出る確率" }
  end

  def topic_for_both_5(geq: true)
    topic_for_both(5, geq: geq)
  end

  def topic_for_both_and_at_least_once(both_coin, at_least_once_coin, geq: true)
    key = :"both_#{both_coin}_and_at_least_once_#{at_least_once_coin}"
    text = "両ターン共に#{both_coin}金が出て、かつ一度でも#{at_least_once_coin}金#{geq ? '以上' : '' }が出る確率"
    { key => text }
  end

  def topic_for_trashing_estate
    { trashing_estate: '屋敷を廃棄できる確率' }
  end

  def topic_for_trashing_estate_and_at_least_once(coin, geq: true)
    { "trashing_estate_and_at_least_once_#{coin}": "屋敷を廃棄しつつ1度でも#{coin}金#{geq ? '以上' : ''}が出る確率" }
  end

  def topic_for_trashing_estate_and_at_least_once_5(geq: true)
    topic_for_trashing_estate_and_at_least_once(5, geq: geq)
  end
end

class Tactic
  # @return [Symbol]
  COPPER = :c
  # @return [Symbol]
  SILVER = :s
  # @return [Symbol]
  ESTATE = :e
  # @return [Symbol]
  ACTION = :a

  include CommonResults
  include CommonTopics

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
