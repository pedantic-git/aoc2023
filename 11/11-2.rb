#!/usr/bin/env ruby

grid = ARGF.readlines
# Get the height and width of the grid before we work out where all the galaxies are
h,w = grid.length, grid[0].chomp.length
# Locate the galaxies
coords = grid.flat_map.with_index {|l,y| l.chomp.chars.map.with_index {|c,x| [y,x] if c == '#'}}.compact

# Find the rows and columns that need expanding
blank_y = 0.upto(h-1).to_a - coords.map(&:first)
blank_x = 0.upto(w-1).to_a - coords.map(&:last)

# Expand the coords
coords.map! do |y,x|
  # A coord needs expanding by the number of blank rows to the left of it (multiplied by the final size - 1)
  [y + blank_y.select {_1 < y}.length*999999, x + blank_x.select {_1 < x}.length*999999]
end

# Distance between two coords
def dist((y1,x1),(y2,x2))
  (y2-y1).abs + (x2-x1).abs
end

pairs = coords.product(coords).map(&:sort).uniq.reject {_1==_2}
p pairs.map {dist(_1,_2)}.sum

