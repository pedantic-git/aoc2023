#!/usr/bin/env ruby

require 'bundler/inline'
require 'matrix'

gemfile do
  source 'https://rubygems.org'
  gem 'colorize'
end

class Crucible
  attr_reader :blocks, :start, :stop, :openset, :camefrom, :gscore, :fscore

  def initialize(matrix)
    @blocks = matrix
    @start = [0,0]
    @stop = [last_row, last_col]
    @openset = Set.new([start])
    @camefrom = {}
    @gscore = Hash.new(Float::INFINITY)
    @gscore[start] = 0
    @fscore = Hash.new(Float::INFINITY)
    fscore[start] = heuristic(start)
  end

  def last_row; blocks.column_size-1 end
  def last_col; blocks.row_size-1 end

  def heuristic(node)
    # Let's go for the sum of all the scores to the right then down - it's not the
    # most efficient but it is admissible
    rights = blocks.row(node[0])[node[1]+1..last_col]
    downs = blocks.column(last_col)[node[0]+1..last_row]
    rights.sum + downs.sum
  end

  OPPOSITE = {north: :south, east: :west, south: :north, west: :east}

  def neighbours(node)
    last_3_dirs = path(node).last(4).each_cons(2).map {[_2[0]-_1[0], _2[1]-_1[1]]}
    p last_3_dirs
    puts self.to_s(node)

    # Explore east and south before west and north for obvious reasons
    possible_dirs = [[0,1], [1,0], [0,-1], [-1,0]]
    # Don't reverse
    if last_3_dirs.last
      possible_dirs.delete([last_3_dirs.last[0]*-1, last_3_dirs.last[1]*-1])
    end
    # If the last 3 directions were the same, don't go that way
    if last_3_dirs.length == 3 && last_3_dirs.uniq.length == 1
      possible_dirs.delete(last_3_dirs.last)
    end
    p possible_dirs
    puts
    # Return all that's left unless it's out of bounds
    possible_dirs.map {|y,x| [node[0]+y, node[1]+x]}.select do |r,c|
      (0..last_row) === r && (0..last_col) === c
    end
  end

  def run!
    while openset.any?
      current = openset.min_by {fscore[_1]}
      return if current == stop
      openset.delete(current)

      neighbours(current).each do |candidate|
        tentative = gscore[current] + blocks[*candidate]
        if tentative < gscore[candidate]
          camefrom[candidate] = current
          gscore[candidate] = tentative
          fscore[candidate] = tentative + heuristic(candidate)
          openset << candidate
        end
      end
    end
    fail "Failed to find path"
  end

  # Once it's run, we can reconstruct the path from camefrom
  def path(node=stop)
    [node].tap do |p|
      while camefrom.key? p[0]
        p.unshift(camefrom[p[0]])
      end
    end
  end

  # Work out the total heat loss
  def heatloss
    path[1..-1].map {blocks[*_1]}.sum
  end

  # Print a nice picture of the city
  def colorized(node=stop)
    blocks.clone.tap do |bs|
      p = Set.new(path node)
      bs.each_with_index {|b,y,x| bs[y,x] = p===[y,x] ? b.to_s.colorize(color: :green, mode: :bold) : b.to_s.colorize(:grey)}
    end
  end

  def to_s(node=stop)
    colorized(node).to_a.map(&:join).join("\n")
  end
end

c = Crucible.new(Matrix[*ARGF.map {_1.chomp.chars.map(&:to_i)}])
c.run!
puts c
puts c.heatloss