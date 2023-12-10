#!/usr/bin/env ruby

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'colorize'
end

# Let's do something completely unnecessary and paint this visually

grid = ARGF.read.tr('-|LJ7F.S', '─│└┘┐┌ ★').lines.map(&:chomp)
# Find the location of ★
sy = grid.index {/★/ =~ _1}
sx = grid[sy].index('★')
grid.map! {_1.split('')}

CONNECTIONS = {
  # North
  [-1,0] => {
    now:  %w{★ │ ┘ └},
    next: %w{★ │ ┐ ┌}
  },
  # East
  [0,1] => {
    now:  %w{★ ─ └ ┌},
    next: %w{★ ─ ┐ ┘}
  },
  # South
  [1,0] => {
    now:  %w{★ │ ┐ ┌},
    next: %w[★ │ └ ┘]
  },
  # West
  [0,-1] => {
    now:  %w{★ ─ ┐ ┘},
    next: %w{★ ─ └ ┌}
  }
}

# First, work out where the pipe is
pipe = [[sy,sx]]
loop do
  CONNECTIONS.each do |(yd,xd),valid|
    # Check the current pipe can accept a connection in this direction
    nowy, nowx = pipe.last
    next unless valid[:now].include? grid[nowy][nowx]
    # Find the next cell in this direction
    y,x = nowy+yd, nowx+xd
    next if y < 0 || x < 0 || y >= grid.length || x >= grid[0].length
    next if [y,x] == pipe[-2] # don't go back on ourself

    if valid[:next].include?(grid[y][x])
      pipe << [y,x]
      break
    end
  end
  break if pipe.last == pipe.first
end

# Get the two sides of the loop - just going clockwise doesn't tell us which is "in" and which is "out" - we can work that out once we have them
# Start with all the non-pipe cells in "lefts"
rights = Set.new
lefts = Set.new((0..grid.length-1).to_a.product((0..grid[0].length-1).to_a)) - pipe

insides = []
pipe.each_cons(2).each do |(fy,fx), (ty,tx)|
  # First find the direction of travel
  dy, dx = ty-fy, tx-fx

  # Now for each symbol, find the cell(s) to the right in the direction of travel
  rcs = case grid[ty][tx]
  when '─'
    # dx is positive we're arriving from the west so add south (and vice versa)
    [[ty+dx, tx]]
  when '│'
    # dy is positive we're arriving from the north so add west (and vice versa)
    [[ty, tx-dy]]
  when '└'
    if dx.zero?
      # Arriving from the north => west, southwest, south
      [[ty, tx-1], [ty+1, tx-1], [ty+1, tx]]
    else
      # Arriving from the east => northeast
      [[ty-1, tx+1]]
    end
  when '┘'
    if dx.zero?
      # Arriving from the north => northwest
      [[ty-1, tx-1]]
    else
      # Arriving from the west => south, southeast, east
      [[ty+1, tx], [ty+1, tx+1], [ty, tx+1]]
    end
  when '┐'
    if dx.zero?
      # Arriving from the south => east, northeast, north
      [[ty, tx+1], [ty-1, tx+1], [ty-1, tx]]
    else
      # Arriving from the west => southwest
      [[ty+1, tx-1]]
    end
  when '┌'
    if dx.zero?
      # Arriving from the south => southeast
      [[ty+1, tx+1]]
    else
      # Arriving from the east => north, northwest, west
      [[ty-1, tx], [ty-1, tx-1], [ty, tx-1]]
    end
  else
    []
  end

  rcs.each do |ry,rx|
    unless ry < 0 || rx < 0 || ry >= grid.length || rx >= grid[0].length || pipe.include?([ry,rx])
      rights << [ry,rx]
      lefts.delete([ry,rx])
    end
  end
end

# lefts that are adjacent to rights need to be moved to rights
queue = rights.to_a
until queue.empty?
  ny,nx = queue.shift
  [[ny-1,nx],[ny,nx+1],[ny+1,nx],[ny,nx-1]].each do |neighbour|
    if lefts.include?(neighbour)
      lefts.delete(neighbour)
      rights << neighbour
      queue << neighbour # we need to examine this one too
    end
  end
end

# The inside is whichever side doesn't include 0,0
inside = lefts.include?([0,0]) ? rights : lefts

pipe.each do |y,x| 
  if [y,x] == pipe[0]
    grid[y][x] = grid[y][x].light_yellow
  else
    grid[y][x] = grid[y][x].light_green
  end
end

rights.each do |y,x|
  grid[y][x] = grid[y][x].on_magenta
end
lefts.each do |y,x|
  grid[y][x] = grid[y][x].on_blue
end

puts grid.map {_1.join}

p "Part 1: #{pipe.length / 2}"
p "Part 2: #{inside.length}"
