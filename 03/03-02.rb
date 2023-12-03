#!/usr/bin/env ruby

# Load the input into a 2d array
grid = ARGF.map {_1.chomp.chars}

gears = {}

# Firstly, find the number, then check if it's adjacent to a star valid part number
# Returns [g,n,m] where g is the coordinates of the potential gear or nil if it's invalid
# n is the number or nil if it's invalid and m is the number of spaces
# to advance the pointer
def check_num(grid, y,x)
  orig_x = x
  num = grid[y][x]
  while /\d/ =~ grid[y][x+1]
    num += grid[y][x+1]
    x+=1
  end
  # OK - we've found the number - now to check its surrounding squares for symbols
  (y-1..y+1).each do |cy|
    (orig_x-1..orig_x+num.length).each do |cx|
      if grid.dig(cy,cx)&.== '*'
        return [[cy,cx], num.to_i, num.length-1]
      end
    end
  end
  [nil, nil, num.length-1]
end

# Iterate through the grid and stop to do some checking whenever we find a digit
grid.each.with_index do |row,y|
  x = 0
  while x < row.length
    # There are more elegant ways of doing this - it feels a bit C-ugh
    if /\d/ =~ grid[y][x]
      g,n,m = check_num(grid, y,x)
      if g
        gears[g] ||= []
        gears[g] << n
      end
      x += m
    end
    x += 1
  end
end

# They're only gears if they have exactly 2 numbers
gears.reject! {|k,v| v.length != 2}

p gears.values.map {_1.reduce(:*)}.sum

