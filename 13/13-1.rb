#!/usr/bin/env ruby

require 'matrix'

class Grid
  attr_accessor :m
  def initialize(str)
    @m = Matrix[*str.split("\n").map(&:chars)]
  end

  def to_s
    m.to_a.map {_1.join}.join("\n") + "\n"
  end

  # Find the mirror - if it's a row multiply by 100
  def score
    0.upto(m.column_count-1).find { is_mirror(_1, :column) }&.then {|i|i+1} ||
    0.upto(m.row_count-1).find { is_mirror(_1, :row) }&.then{|i| (i+1)*100} ||
    raise("Mirror not found!")
  end

  private

  # Is the given row/column index abutting a mirror?
  def is_mirror(i, dir=:row)
    offset = 0
    loop do
      fore, aft = m.public_send(dir, i-offset), m.public_send(dir, i+offset+1)
      return true if offset != 0 && aft.nil?
      return false if fore != aft
      offset += 1
      return true if i-offset < 0
    end
  end
end


grids = ARGF.read.split("\n\n").map {Grid.new _1}

p grids.map(&:score).sum

