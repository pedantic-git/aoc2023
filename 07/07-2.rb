#!/usr/bin/env ruby

class Hand
  CRANKS = "AKQT98765432J".split('')
  TYPES = %i[five four fullhouse three twopair pair highcard]

  attr_reader :cards

  def initialize(cards)
    @cards = cards.split('')
  end

  # Returns a series of integers that can be used to score the hand - lower is better.
  def scores
    [TYPES.index(type)] + cards.map {CRANKS.index(_1)}
  end

  # Returns the type of hand
  def type
    freqs = cards.tally
    jokers = freqs.delete('J') || 0

    # :five happens if:
    # AAAAA / AAAAJ / AAAJJ / AAJJJ / AJJJJ / JJJJJ
    # :four happens if:
    # AAAAB / AAABJ / AABJJ / ABJJJ
    # :fullhouse happens if:
    # AAABB / AABBJ
    # :three happens if:
    # AAABC / AABCJ / ABCJJ
    # :twopair happens if:
    # AABBC
    # :pair happens if
    # AABCD / ABCDJ
    # :highcard happens if:
    # ABCDE

    case freqs.length
    when 5
      :highcard
    when 4
      :pair
    when 3
      if freqs.values.max == 3 || jokers > 0
        :three
      else
        :twopair
      end
    when 2
      case [freqs.values.max, jokers]
      when [4,0], [3,1], [2,2], [1,3]
        :four
      else
        :fullhouse
      end
    else
      # All cards the same after removing jokers - 5 of a kind
      :five
    end
  end

  # Puts lower value hands at the start
  def <=>(other)
    scores <=> other.scores
  end

  # For debugging
  def inspect
    "#{cards.join} #{type}"
  end
end

hands = ARGF.inject({}) {|h,l| l.split(' ').then {h[Hand.new _1] = _2.to_i; h}}
hands_in_order = hands.keys.sort
#hands_in_order.each {p _1}
winnings = hands_in_order.map.with_index {|h,i| hands[h] * (hands.length-i)}
p winnings.sum
