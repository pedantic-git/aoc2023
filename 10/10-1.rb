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

connections = {
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

pipe = [[sy,sx]]
loop do
  connections.each do |(yd,xd),valid|
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

pipe.each do |y,x| 
  if [y,x] == pipe[0]
    grid[y][x] = grid[y][x].light_yellow
  else
    grid[y][x] = grid[y][x].light_green
  end
end

puts grid.map {_1.join}

p pipe.length / 2
