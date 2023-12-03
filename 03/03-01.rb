#!/usr/bin/env ruby

# Load the input into a 2d array
grid = ARGF.map {_1.chomp.chars}

nums = []


# Firstly, find the number, then check if it's a valid part number
# Returns [n,m] where n is the number or nil if it's invalid and m is the number of spaces
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
      if grid.dig(cy, cx) && /[\d.]/ !~ grid[cy][cx]
        return [num.to_i, num.length-1]
      end
    end
  end
  [nil, num.length-1]
end

# Iterate through the grid and stop to do some checking whenever we find a digit
grid.each.with_index do |row,y|
  x = 0
  while x < row.length
    # There are more elegant ways of doing this - it feels a bit C-ugh
    if /\d/ =~ grid[y][x]
      n,m = check_num(grid, y,x)
      nums << n if n
      x += m
    end
    x += 1
  end
end

p nums.sum