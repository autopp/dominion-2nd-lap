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
    (0...12).to_a.permutation(5).map do |others|
      deck = Array.new(12) { :c }
      deck[others[0]] = ESTATE
      deck[others[1]] = ESTATE
      deck[others[2]] = ESTATE
      deck[others[3]] = BG
      deck[others[4]] = partner
      deck
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
  def choose_border_guard(hand)
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

  def simulate_turn(hand)
    coin = 0
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SILVER
        coin += 2
      end
    end

    { coin: coin }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      least_one_5: least_one_5?(t3, t4),
      least_one_6: least_one_6?(t3, t4)
    }
  end

  def topics
    {
      least_one_5: '一度でも5金以上が出る確率',
      least_one_6: '一度でも6金が出る確率'
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
    use = false
    trashed_estate = false
    hand.each do |card|
      case card
      when COPPER
        coin += 1
      when SALVAGER
        use = true
        if hand.include?(ESTATE)
          coin += 2
          trashed_estate = true
        end
      end
    end

    over4_buy2 = trashed_estate && coin >= 4

    { coin: coin, trashed_estate: trashed_estate, over4_buy2: over4_buy2 }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      least_one_5: least_one_5?(t3, t4),
      trashed_estate: or_for(t3, t4, :trashed_estate),
      trashed_estate_least_one_5: or_for(t3, t4, :trashed_estate) && least_one_5?(t3, t4),
      over4_buy2: or_for(t3, t4, :over4_buy2)
    }
  end

  def topics
    {
      least_one_5: '一度でも5金以上が出る確率',
      trashed_estate: '屋敷を廃棄できる確率',
      trashed_estate_least_one_5: '屋敷を廃棄しつつ一度でも5金以上が出る確率',
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
      least_one_5: least_one_5?(t3, t4),
      least_one_6: least_one_6?(t3, t4),
      least_one_7: least_one_7?(t3, t4),
      both_5: both_5?(t3, t4),
      both_5_and_least_one_6: both_5?(t3, t4) && least_one_6?(t3, t4),
      neet: and_for(t3, t4, :neet)
    }
  end

  def topics
    {
      least_one_5: '一度でも5金以上が出る確率',
      least_one_6: '一度でも6金以上が出る確率',
      least_one_7: '一度でも7金が出る確率',
      both_5: '両ターン共に5金以上が出る確率',
      both_5_and_least_one_6: '両ターン共に5金以上を出し、かつ一度でも6金以上が出る確率',
      neet: '男爵が沈む、あるいはニート男爵になる確率'
    }
  end
end

BorderGuardWithSilver.new.report
puts
BorderGuardWithSalvager.new.report
puts
BorderGuardWithBaron.new.report
