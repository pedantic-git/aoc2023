#!/usr/bin/env ruby

require 'matrix'

class Hailstone
  attr_reader :pos, :vel
  def initialize(px,py,vx,vy)
    @pos = Vector[px,py,0.0] # assume the height is always zero
    @vel = Vector[vx,vy,0.0]
  end

  # https://web.archive.org/web/20180927042445/http://mathforum.org/library/drmath/view/62814.html
  def intersection(other)
    time = ((other.pos-pos).cross(other.vel)).r / vel.cross(other.vel).r
    pos + time * vel
  end

  # Do the two hailstones intersect within the given range?
  def intersect?(other, r=200000000000000..400000000000000)
    intersection(other).then {|i| r===i[0] && r===i[1]}
  end

  def inspect
    "#<H #{pos[0]},#{pos[1]} @ #{vel[0]},#{vel[1]}>"
  end

end

hailstones = ARGF.map {Hailstone.new */([-\d]+),\s*([-\d]+),\s*[-\d]+\s*\@\s*([-\d]+),\s*([-\d]+)/.match(_1).captures.map(&:to_f)}
matches = hailstones.product(hailstones).select {|h1, h2| h1 != h2 && h1.intersect?(h2, 7..27)}
require 'pry'
binding.pry

