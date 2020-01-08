require_relative 'helpers'

class Tactic
  # @return [Symbol]
  COPPER = :c
  # @return [Symbol]
  SILVER = :s
  # @return [Symbol]
  ESTATE = :e
  # @return [Symbol]
  ACTION = :a

  include ResultHelper
  include TopicHelper
  include GenDecksHelper

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
  # @return [Array(Array<Symbol>, Array<Symbol>)]
  #
  def split_to_hands(deck, **_opts)
    [deck[0...5].sort!, deck[5...10].sort!]
  end

  # patterns_of_lap creates patterns for each deck with additional infomation
  #
  # Default implemention returns with no factor and no opts
  #
  # @param [Array(Array<Symbol>, Array<Symbol>)] deck deck created by split_to_hands
  #
  # @return [Array<Hash>]
  #   * :factor [Integer] factor of this pattern
  #   * :opts [Hash<Symbol, Object>] additional infomation to pass to simulate_turn
  #
  def patterns_of_deck
    [
      { factor: 1, opts: {} }
    ]
  end

  # simulate_turn simulates each turn and return results as Hash
  #
  # @param [Array<Symbol>] hand hand of this turn
  # @param [Hash] **opts
  #
  # @return [Hash] result
  #   * :coin [Integer] coin of this turn
  #
  def simulate_turn(_hand, **_opts)
    raise NotImplementedError
  end

  # simulate do 2nd lap of deck and return the result
  #
  # @param [Array(Array<Symbol>, Array<Symbol>, Array<Symbol>)] deck the deck of 2nd lap
  #
  # @return [Hash<Symbol, Boolean>]
  #
  def simulate(_deck, **_opts)
    raise NotImplementedError
  end

  # simulate_all returns all patterns of this storategy
  #
  # @return [Array<Hash<Symbol, Boolean>>]
  #
  def simulate_all
    decks = gen_decks.map { |deck| split_to_hands(deck) }.tally
    patterns = patterns_of_deck
    decks.flat_map do |deck, count|
      patterns.map do |pattern|
        { results: simulate(deck, **pattern[:opts]), factor: pattern[:factor] * count }
      end
    end
  end

  # topics returns items of repot
  #
  # @return [Hash<Symbol, String>]
  #
  def topics
    raise NotImplementedError
  end

  def report
    all_patterns = simulate_all
    all = all_patterns.sum { |pattern| pattern[:factor] }
    topics.each do |topic, text|
      count = all_patterns.sum { |pattern| pattern[:results][topic] ? pattern[:factor] : 0 }
      puts "- #{text}: #{(count / all.to_f * 100).round(2)}%"
    end
  end
end
