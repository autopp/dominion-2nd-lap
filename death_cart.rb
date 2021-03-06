require_relative 'tactic'

class DeathCart < Tactic
  DEATH_CART = :death_cart
  RUIN = :ruin
  ABANDONED_MINE = :abandoned_mine

  def gen_decks
    raise NotImplementedError
  end

  def simulate_turn(hand)
    coin = sum_of_coin(hand)
    coin += 1 if hand.include?(ABANDONED_MINE) && !hand.include?(DEATH_CART)

    additional_coin, trashings = process_death_cart(hand, coin)
    { coin: coin + additional_coin, **trashings }
  end

  def simulate(deck)
    hand3, hand4 = deck
    t3 = simulate_turn(hand3)
    t4 = simulate_turn(hand4)

    {
      **result_of_at_least_onces(t3, t4, 5, 6, 7, 8),
      **result_of_both_5(t3, t4),
      **result_of_any(t3, t4, :trashing_ruin),
      **result_of_any(t3, t4, :trashing_death_cart)
    }
  end

  def topics
    {
      **topic_for_at_least_once_5,
      **topic_for_at_least_once_6,
      **topic_for_at_least_once_7,
      **topic_for_at_least_once_8,
      **topic_for_both_5,
      trashing_ruin: '廃墟を廃棄できる確率',
      trashing_death_cart: '死の荷車を廃棄することになる確率'
    }
  end

  private

  def process_death_cart(hand, coin)
    if hand.member?(DEATH_CART) && coin < 5
      if hand.member?(RUIN) || hand.member?(ABANDONED_MINE)
        [5, { trashing_ruin: true, trashing_death_cart: false }]
      else
        [5, { trashing_ruin: false, trashing_death_cart: true }]
      end
    else
      [0, { trashing_ruin: false, trashing_death_cart: false }]
    end
  end
end

class DeathCartWithSilver < DeathCart
  def title
    '屋敷場かつ銀貨・死の荷車で廃墟は2枚とも廃村だった場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(14) do |factory, other_indices|
      other_indices.combination(2).flat_map do |ruins|
        (other_indices - ruins).permutation(2).map do |(silver, death_cart)|
          factory.new_deck do |deck|
            deck[ruins[0]] = RUIN
            deck[ruins[1]] = RUIN
            deck[silver] = SILVER
            deck[death_cart] = DEATH_CART
          end
        end
      end
    end
  end
end

class DeathCartWithSilverAndMine < DeathCart
  def title
    '屋敷場かつ銀貨・死の荷車で廃墟は廃村と廃坑だった場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(14) do |factory, other_indices|
      other_indices.permutation(4).map do |(ruin, mine, silver, death_cart)|
        factory.new_deck do |deck|
          deck[ruin] = RUIN
          deck[mine] = ABANDONED_MINE
          deck[silver] = SILVER
          deck[death_cart] = DEATH_CART
        end
      end
    end
  end
end

class DeathCartOnly < DeathCart
  def title
    '屋敷場かつ死の荷車・パスで廃墟は2枚とも廃村だった場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(13) do |factory, other_indices|
      other_indices.combination(2).flat_map do |ruins|
        (other_indices - ruins).map do |death_cart|
          factory.new_deck do |deck|
            deck[ruins[0]] = RUIN
            deck[ruins[1]] = RUIN
            deck[death_cart] = DEATH_CART
          end
        end
      end
    end
  end
end

class DeathCartAndMine < DeathCart
  def title
    '屋敷場かつ死の荷車・パスで廃墟は廃村と廃坑だった場合、4ターン目までに……'
  end

  def gen_decks
    with_combination_of_estates(13) do |factory, other_indices|
      other_indices.permutation(3).map do |(ruin, mine, death_cart)|
        factory.new_deck do |deck|
          deck[ruin] = RUIN
          deck[mine] = ABANDONED_MINE
          deck[death_cart] = DEATH_CART
        end
      end
    end
  end
end

DeathCartWithSilver.new.report
puts
DeathCartWithSilverAndMine.new.report
puts
DeathCartOnly.new.report
puts
DeathCartAndMine.new.report
