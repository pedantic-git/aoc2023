#!/usr/bin/env ruby

class Hand
  TYPES = [/(.)\1{4}/, /(.)\1{3}/, /(.)\1\1(.)\2/, /(.)\1\1/, /(.)\1(.?)(.)\3/, /(.)\1/, /(.)/].freeze
  CRANKS = "AKQJT98765432".split('')

  attr_reader :cards

  def initialize(cards)
    @cards = cards.split('').sort_by {CRANKS.index(_1)}.join
  end

  # Returns a series of integers that can be used to score the hand - lower is better.
  def scores
    type = TYPES.each_index.find {TYPES[_1] =~ cards}

    # Type 4 has three capture groups, so handle it differently
    winning_cards = (type == 4 ? [$1,$3] : [$1,$2]).compact
    non_winning_cards = ($`+(type == 4 ? $2 : '')+$').split('').uniq
    [type] + (winning_cards + non_winning_cards).map {CRANKS.index(_1)}
  end

  # Puts lower value hands at the start
  def <=>(other)
    scores <=> other.scores
  end

  # For debugging
  def inspect
    types = %i[five four fullhouse three twopair pair highcard]
    s = scores
    "#{cards} #{types[s.shift]} #{s.map {CRANKS[_1]}.inspect}"
  end
end

hands = ARGF.inject({}) {|h,l| l.split(' ').then {h[Hand.new _1] = _2.to_i; h}}
hands.keys.each {p _1}
# winnings = hands.keys.sort.map.with_index {|h,i| hands[h] * (hands.length-i)}
# p winnings.sum
