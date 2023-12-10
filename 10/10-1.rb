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
side1 = Set.new
side2 = Set.new((0..grid.length-1).to_a.product((0..grid[0].length-1).to_a)) - pipe

insides = []
pipe.each_cons(2).each do |(fy,fx), (ty,tx)|
  # north = -1,0 => 0,1
  # east = 0,1 => 1,0
  # south = 1,0 => 0,-1
  # west = 0,-1 => -1,0
  # y = y+dx
  # x = x+dy*-1
  y, x = ty+tx-fx, tx+fy-ty
  next if y < 0 || x < 0 || y >= grid.length || x >= grid[0].length
  next if pipe.include? [y,x]
  # If it's to the right we move it from side2 to side1
  side2.delete([y,x]) && side1 << [y,x]
end

# Elements of side2 that are adjacent to elements of side1 need to be moved to side1
queue = side1.to_a
until queue.empty?
  ny,nx = queue.shift
  [[ny-1,nx],[ny,nx+1],[ny+1,nx],[ny,nx-1]].each do |neighbour|
    if side2.include?(neighbour)
      side2.delete(neighbour)
      side1 << neighbour
      queue << neighbour # we need to examine this one too
    end
  end
end

# The inside is whichever side doesn't include 0,0
inside = side1.include?([0,0]) ? side2 : side1

pipe.each do |y,x| 
  if [y,x] == pipe[0]
    grid[y][x] = grid[y][x].light_yellow
  else
    grid[y][x] = grid[y][x].light_green
  end
end

side1.each do |y,x|
  grid[y][x] = grid[y][x].on_magenta
end
side2.each do |y,x|
  grid[y][x] = grid[y][x].on_blue
end

puts grid.map {_1.join}

p "Part 1: #{pipe.length / 2}"
p "Part 2: #{inside.length}"
