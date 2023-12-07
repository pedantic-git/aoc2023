#!/usr/bin/env ruby

class Hand
  TYPES = [/(.)\1{4}/, /(.)\1{3}/, /^(.)\1\1?(.)\2\2?$/, /(.)\1\1/, /(.)\1.?(.)\2/, /(.)\1/, /(.)/].freeze
  CRANKS = "AKQJT98765432".split('')

  attr_reader :cards, :cards_sorted

  def initialize(cards)
    @cards = cards.split('')
    @cards_sorted = @cards.sort_by {CRANKS.index(_1)}.join
  end

  # Returns a series of integers that can be used to score the hand - lower is better.
  def scores
    type = TYPES.each_index.find {TYPES[_1] =~ cards_sorted}
    [type] + cards.map {CRANKS.index(_1)}
  end

  # Puts lower value hands at the start
  def <=>(other)
    scores <=> other.scores
  end

  # For debugging
  def inspect
    types = %i[five four fullhouse three twopair pair highcard]
    "#{cards.join} #{types[scores.shift]} (#{cards_sorted})"
  end
end

hands = ARGF.inject({}) {|h,l| l.split(' ').then {h[Hand.new _1] = _2.to_i; h}}
hands_in_order = hands.keys.sort
#hands_in_order.each {p _1}
winnings = hands_in_order.map.with_index {|h,i| hands[h] * (hands.length-i)}
p winnings.sum
