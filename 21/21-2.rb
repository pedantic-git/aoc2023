#!/usr/bin/env ruby

require 'pry'
require_relative '../grid'

class Garden < Grid
  attr_reader :initial_se

  def initialize(io)
    super
    @initial_se = se_corner
  end

  def run!(steps)
    steps.times do |n| 
      step!
      puts "#{n+1},#{answer}"
    end
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

  # Any index is valid - just find the % if it's not in the set
  def [](*v)
    v = cast_vector(v)
    phantom_coords = Vector[v[0] % (initial_se[0]+1), v[1] % (initial_se[1]+1)]
    # Return a phantom # or . if we're looking outside our usual bounds. Don't return S unless it's been explicitly set
    @cells[v] || (@cells[phantom_coords] == '#' ? '#':'.')
  end

  # Expand the corners if we've moved out of the bounds
  def to_s
    set_corners!
    super
  end

  # All moves are valid
  def move(m, v=cursor)
    (v + m)
  end
end

g = Garden.new(ARGF)
g.run! 300
#puts g
