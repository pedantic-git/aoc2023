#!/usr/bin/env ruby

require 'pry'
require_relative '../grid'

class Garden < Grid

  def initialize(io)
    super
  end

  def run!(steps)
    steps.times { step! }
  end

  # Find all the 'S' in the grid. Set them all back to '.' and set their
  # neighbours to 'S' - taking one step
  def step!
    select {|v,c| c == 'S'}.each do |v,c|
      self[v] = '.'
      neighbours(v) {|nv,nc| nc != '#'}.each do |nv,nc|
        self[nv] = 'S'
      end
    end
  end

  def color(v,c)
    return {color: :red, mode: :bold} if c == 'S'
    super
  end

  def answer
    count {|v,c| c == 'S'}
  end
end

steps = ARGV.shift.to_i
g = Garden.new(ARGF)
g.run! steps
puts g
puts g.answer
