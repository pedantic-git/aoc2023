#!/usr/bin/env ruby

class Range
  # Monkeypatch the missing #overlap? method into Range
  def overlap?(other)
    self.begin <= other.last && self.last >= other.first
  end
end

class Block
  # To make debugging easier
  @@label = 0

  attr_reader :label
  attr_accessor :x, :y, :z
  def initialize(x1,y1,z1,x2,y2,z2, label=nil)
    if label.nil?
      @label = @@label.to_s(26).tr '0-9a-p', 'A-Z'
      @@label += 1
    end
    @x = x1..x2
    @y = y1..y2
    @z = z1..z2
  end

  def inspect
    "#<Block #{label} #{x.begin},#{y.begin},#{z.begin}-#{x.end},#{y.end},#{z.end}>"
  end

  # Does this block overlap with another block?
  def overlap?(other)
    x.overlap?(other.x) && y.overlap?(other.y) && z.overlap?(other.z)
  end

  # Is this block supporting another block?
  def supporting?(other)
    z.end == other.z.begin-1 && x.overlap?(other.x) && y.overlap?(other.y)
  end

  # Is this block at the bottom?
  def bottom?
    z.begin == 1
  end

  # Drop this block by 1
  def drop!
    self.z = (z.begin-1)..(z.end-1)
  end

end

class Stack < Set
  def run!
    while drop!; end
  end

  def drop!
    to_drop = supported_by.select {|k,v| v.empty? && !k.bottom?}.keys
    to_drop.each(&:drop!)
    !to_drop.empty? # return false when everything is settled
  end

  # Check no blocks overlap each other - if they do, something has gone wrong
  # Only used for debugging
  def sane?
    !to_a.product(to_a).reject {|a,b| a==b}.map {_1.reduce(&:overlap?)}.any?
  end

  # Find the blocks each block is supporting
  def supports
    to_h {|block| [block, select {|other| block.supporting? other}]}
  end

  # The inverse, find what blocks are supporting each one
  def supported_by
    to_h {|block| [block, select {|other| other.supporting? block}]}
  end

  # Find the blocks that are safe to disintegrate
  def safe
    # Count the number of times each block appears on the rhs of supports
    info = supports
    tally = info.values.flatten.tally
    # Reject those entries where one of the "1" answers is on the rhs
    info.reject {|k,v| v.any? {tally[_1] == 1}}.keys
  end

end

stack = Stack.new(ARGF.map {Block.new *_1.scan(/\d+/).map(&:to_i)})
stack.run!
p stack.safe.size
