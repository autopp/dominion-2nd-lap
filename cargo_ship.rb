require_relative 'tactic'

class CargoShip < Tactic
  def split_to_hands(deck)
    [deck[0...5].sort!]
  end

  def simulate_turn(hand)
    action_included = hand.include?(ACTION)
    coin = sum_of_coin(hand)
    coin += 2 if action_included
    { coin: coin, set_aside: action_included }
  end

  def simulate(deck)
    hand3 = deck.first
    t3 = simulate_turn(hand3)

    {
      set_aside_5: set_aside?(t3, 5),
      set_aside_6: set_aside?(t3, 6)
    }
  end

  def topics
    {
      set_aside_5: '5コスト以上のカードをプレイできる確率',
      set_aside_6: '6コスト以上のカードをプレイできる確率'
    }
  end

  private

  def set_aside?(t, coin)
    t[:coin] >= coin && t[:set_aside]
  end
end

class CargoShipWithSilver < CargoShip
  def title
    '銀貨・貨物船で4ターン目までに……'
  end

  include GenDecksWithSilverAndAction
end

class DoubleCargoShip < CargoShip
  def title
    '貨物船・貨物船で4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(12) do |factory, other_indices|
      other_indices.combination(2).map do |(action1, action2)|
        factory.new_deck do |deck|
          deck[action1] = ACTION
          deck[action2] = ACTION
        end
      end
    end
  end
end

CargoShipWithSilver.new.report
puts
DoubleCargoShip.new.report
