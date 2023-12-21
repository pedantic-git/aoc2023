#!/usr/bin/env ruby

require 'pry'
require_relative '../grid'

class Garden < Grid

  def initialize(io)
    super
    self.cursor = find {|v,c| c == 'S'}[0]
  end

  def walk!(steps)
    to_explore = neighbours {|v,c| c != '#'}
    if steps-1 == 0 || neighbours.empty?
      to_explore.each {|v,c| self[v] = 'O'}
      return
    end
    to_explore.each do |v|
      self.cursor = v
      walk! steps-1
    end
  end

  def color(v,c)
    return {color: :red, mode: :bold} if c == 'S'
    return {color: :green, mode: :bold} if c == 'O'
    super
  end

  def answer
    count {|v,c| c == 'O'}
  end
end

steps = ARGV.shift.to_i
g = Garden.new(ARGF)
g.walk! steps
puts g
puts g.answer

