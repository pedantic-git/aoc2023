#!/usr/bin/env ruby

require 'matrix'

class Platform
  attr_accessor :m, :initial

  def initialize(lines)
    @m = Matrix[*lines.map {_1.chomp.chars}]
  end

  def to_s
    m.to_a.map {_1.join + "\n"}.join
  end

  def roll!(dir)
    case dir
    when :north
      0.upto(m.row_size-1) do |ci|
        str = m.column(ci).to_a.join
        str.gsub!(/([O.]+)/) { $1.chars.sort.reverse.join }
        m[0..-1, ci] = Vector[*str.chars]
      end
    when :east
      0.upto(m.column_size-1) do |ri|
        str = m.row(ri).to_a.join
        str.gsub!(/([O.]+)/) { $1.chars.sort.join }
        m[ri, 0..-1] = Vector[*str.chars]
      end
    when :south
      0.upto(m.row_size-1) do |ci|
        str = m.column(ci).to_a.join
        str.gsub!(/([O.]+)/) { $1.chars.sort.join }
        m[0..-1, ci] = Vector[*str.chars]
      end
    when :west
      0.upto(m.column_size-1) do |ri|
        str = m.row(ri).to_a.join
        str.gsub!(/([O.]+)/) { $1.chars.sort.reverse.join }
        m[ri, 0..-1] = Vector[*str.chars]
      end
    end
  end

  def spin!
    %i[north west south east].each {roll! _1}
  end

  def load
    score = 0
    m.each_with_index {|c,y,x| score += m.column_size-y if c == 'O' }
    score
  end

  # Find the period of "after a while the pattern will repeat"
  def find_period
    data = 1000.times.map { spin!; load }
    1.upto(1000) do |t|
      if data.slice(-t, t) == data.slice(-2*t, t)
        return t
      end
    end
    fail "Couldn't find period"
  end

end

plat = Platform.new(ARGF)

# The period for input is 36, which means we should be able to reduce the number of
# iterations by some multiple of 36
# p plat.find_period

# 1000000000-(27777775*36)
100.times { plat.spin! }
p plat.load
