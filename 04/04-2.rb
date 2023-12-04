#!/usr/bin/env ruby

# OK - let's do it properly this time

class Scratchcard
  attr_accessor :id, :copies
  attr_reader :acc, :winning_numbers, :numbers_i_have

  def initialize(h, line)
    /Card +(\d+): (.*) \| (.*)/.match(line)
    @id = $1.to_i
    @acc = h
    @copies = 1
    @winning_numbers = $2.split(' ')
    @numbers_i_have  = $3.split(' ')
    @acc[id] = self
  end

  def process!
    n = (winning_numbers & numbers_i_have).length
    if n > 0
      (id+1).upto(id+n) {acc[_1].copies += copies}
    end
  end
end

acc = {}
ARGF.each {Scratchcard.new acc, _1}
acc.each_value(&:process!)
p acc.values.map(&:copies).sum

