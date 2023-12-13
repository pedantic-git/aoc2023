#!/usr/bin/env ruby

require 'matrix'
require 'pry'

class Grid
  attr_accessor :m, :initial_mirror

  def initialize(str)
    @m = Matrix[*str.split("\n").map(&:chars)]
    @initial_mirror = find_mirror
  end

  def to_s
    m.to_a.map {_1.join}.join("\n") + "\n"
  end

  # Find the mirror - if it's a row multiply by 100
  def score
    # Try each element as a smudge
    m.each_with_index do |e, row, col|
      m[row, col] = (e == '#' ? '.':'#')
      find_mirror.then {return _1 if _1}
      m[row, col] = e
    end
    fail "Unable to find mirror"
  end

  private

  # Find the first mirror we find in the matrix that is not initial_mirror
  def find_mirror
    0.upto(m.column_count-1).find {|i| is_mirror(i, :column) && (i+1 != initial_mirror)}&.then {|i| return i+1}
    0.upto(m.row_count-1).find {|i| is_mirror(i, :row) && ((i+1)*100 != initial_mirror)}&.then{|i| return (i+1)*100}
    return nil
  end

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
