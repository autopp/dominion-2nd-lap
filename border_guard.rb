require_relative 'tactic'

class BorderGuard < Tactic
  BG = :bg

  # partner returns partner of this tactic
  #
  # @return [Symbol]
  #
  def partner
    raise NotImplementedError
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.permutation(2).map do |others|
        factory.new_deck do |deck|
          deck[others[0]] = BG
          deck[others[1]] = partner
        end
      end
    end
  end

  def split_to_hands(deck)
    hands = case deck.find_index(BG)
    when 0...5
      [choose_border_guard(deck[0...7]), deck[7...12]]
    when 5...10
      [deck[0...5], choose_border_guard(deck[5...12])]
    else
      [deck[0...5], deck[5...10]]
    end

    sum = hands.map(&:size).reduce(&:+)
    raise "#{sum} != 11 && #{sum} != 10" if sum != 11 && sum != 10

    hands
  end

  # choose_border_guard reutnrs hand after choosing
  #
  # @param [Array<Symbol>]
  #
  # @return [Array<Symbol>]
  #
  def choose_border_guard(_hand)
    raise NotImplementedError
  end

  # Helper

  # choose_one chooses from revealed according to the priority of order
  #
  # @param [Array<Symbol>] revealed
  # @param [Array<Symbol>] order
  #
  # @return [Symbol]
  #
  def choose_one(revealed, order)
    found = order.find { |x| revealed.include?(x) }
    found || raise("revealed: #{revealed}, order: #{order}")
  end
end

class BorderGuardWithSilver < BorderGuard
  def partner
    SILVER
  end

  def choose_border_guard(hand)
    revealed = hand[5...7]
    hand = hand[0...5]
    choice = choose_one(revealed, [SILVER, COPPER, ESTATE])
    [*hand, choice]
  end

  include SimulateTurnWithSilverOnly

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_once_5(t3, t4),
      **result_of_at_least_once_6(t3, t4)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6(geq: false)
    }
  end
end

class BorderGuardWithSalvager < BorderGuard
  SALVAGER = :salvager

  def partner
    SALVAGER
  end

  def choose_border_guard(hand)
    revealed = hand[5...7]
    hand = hand[0...5]
    choice = if hand.include?(SALVAGER) && !hand.include?(ESTATE)
      choose_one(revealed, [ESTATE, SILVER, COPPER])
    elsif !hand.include?(SALVAGER) && hand.include?(ESTATE)
      choose_one(revealed, [SALVAGER, SILVER, COPPER, ESTATE])
    else
      choose_one(revealed, [SILVER, COPPER, ESTATE, SALVAGER])
    end
    [*hand, choice]
  end

  def simulate_turn(hand)
    coin = 0
    trashing_estate = false
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SALVAGER
        if hand.include?(ESTATE)
          coin += 2
          trashing_estate = true
        end
      end
    end

    over4_buy2 = trashing_estate && coin >= 4

    { coin: coin, trashing_estate: trashing_estate, over4_buy2: over4_buy2 }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      at_least_once_5: at_least_once_5?(t3, t4),
      trashing_estate: any?(t3, t4, :trashing_estate),
      trashing_estate_and_at_least_once_5: any?(t3, t4, :trashing_estate) && at_least_once_5?(t3, t4),
      over4_buy2: any?(t3, t4, :over4_buy2)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_trashing_estate,
      **topic_for_trashing_estate_and_at_least_once_5,
      over4_buy2: '4金以上2購入が出る確率'
    }
  end
end

class BorderGuardWithBaron < BorderGuard
  # @return [Symbol]
  BARON = :baron

  def partner
    BARON
  end

  def choose_border_guard(hand)
    revealed = hand[5...7]
    hand = hand[0...5]
    choice = if hand.include?(BARON) && !hand.include?(ESTATE)
      choose_one(revealed, [ESTATE, SILVER, COPPER])
    elsif !hand.include?(BARON) && hand.include?(ESTATE)
      choose_one(revealed, [BARON, SILVER, COPPER, ESTATE])
    else
      choose_one(revealed, [SILVER, COPPER, ESTATE, BARON])
    end
    [*hand, choice]
  end

  def simulate_turn(hand)
    coin = 0
    neet = true
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when BARON
        if hand.include?(ESTATE)
          coin += 4
          neet = false
        end
      end
    end

    { coin: coin, neet: neet }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      at_least_once_5: at_least_once_5?(t3, t4),
      at_least_once_6: at_least_once_6?(t3, t4),
      at_least_once_7: at_least_once_7?(t3, t4),
      both_5: both_5?(t3, t4),
      both_5_and_at_least_once_6: both_5?(t3, t4) && at_least_once_6?(t3, t4),
      neet: all?(t3, t4, :neet)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once(7, geq: false),
      **topic_for_both_5,
      **topic_for_both_and_at_least_once(5, 6, geq: false),
      neet: '男爵が沈む、あるいはニート男爵になる確率'
    }
  end
end

BorderGuardWithSilver.new.report
puts
BorderGuardWithSalvager.new.report
puts
BorderGuardWithBaron.new.report
