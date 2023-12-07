#!/usr/bin/env ruby

class Hand
  TYPES = [/(.)\1{4}/, /(.)\1{3}/, /(.)\1\1(.)\2/, /(.)\1\1/, /(.)\1.?(.)\2/, /(.)\1/, /(.)/].freeze
  CRANKS = "AKQJT98765432".split('')

  attr_reader :cards

  def initialize(cards)
    @cards = cards.split('').sort.join
  end

  # Determine the two or three ranks that will be used to score this hand -
  # lower is better
  def scores
    type = TYPES.each_index.find {TYPES[_1] =~ cards}
    [type] + [CRANKS.index($1), CRANKS.index($2)].compact.sort
  end

  # Puts lower value hands at the start
  def <=>(other)
    scores <=> other.scores
  end
end

hands = ARGF.inject({}) {|h,l| l.split(' ').then {h[Hand.new _1] = _2.to_i; h}}
winnings = hands.keys.sort.map.with_index {|h,i| hands[h] * (hands.length-i)}
p winnings.sum

