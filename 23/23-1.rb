#!/usr/bin/env ruby

require_relative '../grid'
require 'pry'

class Island < Grid
  attr_reader :start, :stop
  def initialize(io)
    super
    @start = Vector[0,1]
    @stop = se_corner + Vector[0,-1]
  end

  def color(v,c)
    return :green if c == '#'
    return :red if c == 'O'
    :grey
  end

  def heuristic(from, to, start, stop)
    (to-from).reduce(:+)
  end

  def neighbours(v=cursor)
    dirs = %w[^ > v <]
    super.select.with_index {|v,i| self[v] == '.' || self[v] == dirs[i]}.tap {p _1}
  end

  def run!
    path = astar(start, stop)
    path.each {|v| self[v] = 'O'}
  end
end

i = Island.new(ARGF)
i.run!
puts i
