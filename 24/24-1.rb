#!/usr/bin/env ruby

require 'matrix'

class Hailstone
  attr_reader :pos, :vel
  def initialize(px,py,vx,vy)
    @pos = Vector[px,py,0.0] # assume the height is always zero
    @vel = Vector[vx,vy,0.0]
  end

  # https://web.archive.org/web/20180927042445/http://mathforum.org/library/drmath/view/62814.html
  # Return the time of the intersection
  def intersection(other)
    lhs = vel.cross(other.vel)
    return nil if lhs.zero?
    rhs = (other.pos-pos).cross(other.vel)
    sign = rhs[2]*lhs[2] > 0 ? 1:-1
    at((rhs.r / lhs.r) * sign)
  end

  def at(time)
    pos + time * vel
  end

  # Is the given vector in this hailstone's past?
  def past?(v)
    if vel[0] > 0
      pos[0] > v[0]
    else
      pos[0] < v[0]
    end
  end

  # Do the two hailstones intersect within the given range?
  def intersect?(other, r=200000000000000..400000000000000)
    i = intersection(other) or return false
    return false if past?(i) || other.past?(i)
    r === i[0] && r === i[1]
  end

  def inspect
    "#<H #{pos[0]},#{pos[1]} @ #{vel[0]},#{vel[1]}>"
  end

end

hailstones = ARGF.map {Hailstone.new */([-\d]+),\s*([-\d]+),\s*[-\d]+\s*\@\s*([-\d]+),\s*([-\d]+)/.match(_1).captures.map(&:to_f)}
p hailstones.combination(2).count {|h1,h2| h1.intersect?(h2)}
