#!/usr/bin/env ruby

require_relative '../grid'
#require 'pry'

class Garden < Grid

  def initialize(io=nil)
    super
    self.cursor = find {|v,c| c == 'S'}[0]
  end

  def walk!(steps)
  end

  def color(v,c)
    return {color: :red, mode: :bold} if c == 'S'
    super
  end
end

g = Garden.new(ARGF)
puts g
#binding.pry g
