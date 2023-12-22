#!/usr/bin/env ruby

require 'pry'

class Range
  # Monkeypatch the missing #overlap? method into Range
  def overlap?(other)
    self.begin <= other.last && self.last >= other.first
  end
end

class Block
  class BottomError < StandardError; end

  # To make debugging easier
  @@label = "A"

  attr_reader :label
  attr_accessor :x, :y, :z
  def initialize(x1,y1,z1,x2,y2,z2, label=nil)
    if label.nil?
      @label = @@label
      @@label = (@@label.ord+1).chr
    end
    @x = x1..x2
    @y = y1..y2
    @z = z1..z2
  end

  def inspect
    "#<Block #{label} #{x.begin},#{y.begin},#{z.begin}-#{x.end},#{y.end},#{z.end}>"
  end

  # A hypothetical block that represents the space directly below this one
  def below
    raise BottomError, "already at bottom" if z.begin == 1
    Block.new(x.begin, y.begin, z.begin-1, x.end, y.end, z.end-1, "!")
  end

  # Does this block overlap with another block?
  def overlap?(other)
    x.overlap?(other.x) && y.overlap?(other.y) && z.overlap?(other.z)
  end

  # Is this block supporting another block?
  def supporting?(other)
    z.end == other.z.begin-1 && (x.cover?(other.x) || y.cover?(other.y))
  end

  # Drop this block by 1
  def drop!
    raise BottomError, "already at bottom" if z.begin == 1
    self.z = (z.begin-1)..(z.end-1)
  end

end

class Stack < Set
  class SettledError < StandardError; end
  
  # Returns the set sorted by height, lowest first
  def by_height
    sort_by {_1.z.begin}
  end

  def run!
    loop { drop! }
  rescue SettledError
    nil
  end

  def drop!
    dropped = false
    by_height.each do |block|
      below = block.below
      if !any? {below.overlap? _1}
        dropped = true
        block.drop!
      end
    rescue Block::BottomError
      next
    end
    raise SettledError, "blocks have settled" unless dropped
    self
  end

  # Check no blocks overlap each other - if they do, something has gone wrong
  # Only used for debugging
  def sane?
    !to_a.product(to_a).reject {|a,b| a==b}.map {_1.reduce(&:overlap?)}.any?
  end

  # Find the blocks supporting each block
  def supports
    to_h {|block| [block, select {|other| block.supporting? other}]}
  end
end

stack = Stack.new(ARGF.map {Block.new *_1.scan(/\d+/).map(&:to_i)})
binding.pry stack
