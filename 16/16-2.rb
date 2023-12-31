#!/usr/bin/env ruby

require 'bundler/inline'
require 'matrix'

gemfile do
  source 'https://rubygems.org'
  gem 'colorize'
end

Node = Struct.new(:y,:x,:dir)

class Contraption
  attr_accessor :m, :beam, :illuminated

  def initialize(io)
    @m = Matrix[*io.map {_1.chomp.chars}]
  end

  def possible_starts
    (0..m.row_size-1).map {Node.new(0, _1, :south)} +
    (0..m.row_size-1).map {Node.new(m.column_size-1, _1, :north)} +
    (0..m.column_size-1).map {Node.new(_1, 0, :east)} +
    (0..m.column_size-1).map {Node.new(_1, m.row_size-1, :west)}
  end

  def start=(node)
    @beam = [node]
    @illuminated = {}
    update_illuminated!
  end

  # Advance the beam by one space
  def tick!
    @beam = beam.flat_map {follow _1}
    update_illuminated!
  end

  # Run until the beam completely leaves the contraption
  # There's probably a proper way to do this, but we'll just say
  # "if beam_coords has been stable for 100 ticks"
  def run!
    until beam.empty?
      tick!
      #puts "\e[H\e[2J#{self}"
    end
  end

  def to_s
    colorized.to_a.map(&:join).join("\n")
  end

  private

  # Create a colorized version of the matrix
  def colorized
    m.clone.tap do |cm|
      cm.each_with_index {|c,y,x| cm[y,x] = illuminated.key?([y,x]) ? c.colorize(color: :light_cyan, mode: :bold) : c.colorize(:grey)}
    end
  end

  # The next node(s) in the node's direction - may be empty if they fall off the map
  def follow(node)
    case m[node.y,node.x]
    when '.'
      [move(node, node.dir)].compact
    when '/'
      dir = {north: :east, east: :north, south: :west, west: :south}[node.dir]
      [move(node, dir)].compact
    when '\\'
      dir = {north: :west, east: :south, south: :east, west: :north}[node.dir]
      [move(node, dir)].compact
    when '|'
      case node.dir
      when :north, :south
        [move(node, node.dir)].compact
      else
        [move(node, :north), move(node, :south)].compact
      end
    when '-'
      case node.dir
      when :east, :west
        [move(node, node.dir)].compact
      else
        [move(node, :east), move(node, :west)].compact
      end
    end
  end

  DIRS = {north: [-1,0], east: [0,1], south: [1,0], west: [0,-1]}
  # Move a node in a given direction - if it's out of bounds, return nil
  def move(node, dir)
    n = Node.new(node.y + DIRS[dir][0], node.x + DIRS[dir][1], dir)
    if (0..m.column_size-1) === n.y && (0..m.row_size-1) === n.x
      if illuminated[[n.y,n.x]]&.include? n.dir
        return nil # we're in a circle
      else
        return n
      end
    end
    nil
  end

  # Make sure the current value of beam is added to illuminated. Keep track of the
  # direction because we can use this to avoid circles
  def update_illuminated!
    beam.each do |node|
      illuminated[[node.y,node.x]] ||= Set.new
      illuminated[[node.y,node.x]] << node.dir
    end
  end

end

contraption = Contraption.new(ARGF)
max = 0
contraption.possible_starts.each do |s|
  p s.to_a
  contraption.start = s
  contraption.run!
  if contraption.illuminated.size > max
    max = contraption.illuminated.size
    p max
  end
end

p max
