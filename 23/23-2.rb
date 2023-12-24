#!/usr/bin/env ruby

require_relative '../grid'
require 'pry'

class Island < Grid
  attr_reader :start, :stop, :unfinished_paths, :finished_paths
  def initialize(io)
    super
    @start = Vector[0,1]
    @stop = se_corner + Vector[0,-1]
    @unfinished_paths = [[start]]
    @finished_paths = []
  end

  def color(v,c)
    return :green if c == '#'
    return :red if c == 'O'
    :grey
  end

  def neighbours(v=cursor)
    dirs = %w[^ > v <]
    super.select.with_index {|v,i| self[v] != '#'}
  end

  def longest_path
    finished_paths.max_by(&:length)
  end

  def run!
    while path = unfinished_paths.shift
      neighbours(path.last).each do |candidate|
        next if path.include? candidate # don't visit the same space twice
        if candidate == stop
          finished_paths << (path << candidate)
          puts "Found path of #{finished_paths.last.length - 1} steps"
          copy = dup
          finished_paths.last.each {|v| copy[v] = 'O'}
          puts copy
        else
          unfinished_paths << (path.dup << candidate)
        end
      end
    end
    # Colour in the longest path
    longest_path.each {self[_1] = 'O'}
  end
end

i = Island.new(ARGF)
i.run!
puts i
p i.longest_path.length-1 # The initial node is not a step
