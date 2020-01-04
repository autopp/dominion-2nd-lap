module ResultHelper
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

module TopicHelper
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
    text = "両ターン共に#{both_coin}金が出て、かつ一度でも#{at_least_once_coin}金#{geq ? '以上' : ''}が出る確率"
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

module GenDecksHelper
  def with_combination_of_estates(size, num_of_estate: 3)
    indices = (0...size).to_a
    indices.combination(num_of_estate).flat_map do |estates|
      yield estates, indices - estates
    end
  end
end

module GenDecksWithSilverAndAction
  def gen_decks
    with_combination_of_estates(12) do |estates, other_indices|
      other_indices.permutation(2).map do |(silver, action)|
        deck = Array.new(12) { Tactic::COPPER }
        deck[estates[0]] = Tactic::ESTATE
        deck[estates[1]] = Tactic::ESTATE
        deck[estates[2]] = Tactic::ESTATE
        deck[silver] = Tactic::SILVER
        deck[action] = Tactic::ACTION
        deck
      end
    end
  end
end

module GenDecksWithDoubleSilver
  def gen_decks
    with_combination_of_estates(12) do |estates, other_indices|
      other_indices.combination(2).map do |silvers|
        deck = Array.new(12) { Tactic::COPPER }
        deck[estates[0]] = Tactic::ESTATE
        deck[estates[1]] = Tactic::ESTATE
        deck[estates[2]] = Tactic::ESTATE
        deck[silvers[0]] = Tactic::SILVER
        deck[silvers[1]] = Tactic::SILVER
        deck
      end
    end
  end
end

module SimulateTurnWithSilverOnly
  def simulate_turn(hand)
    coin = 0
    hand.each do |card|
      case card
      when Tactic::COPPER
        coin += 1
      when Tactic::SILVER
        coin += 2
      end
    end
    { coin: coin }
  end
end
