#!/usr/bin/env ruby

require 'matrix'
require 'pry'

# No premature optimization, Quinn!!

instructions = ARGF.map {/([UDLR]) (\d+)/.match(_1).captures}

# First, find all the coords of the path with 0,0 as the origin
coords = [[0,0]]
instructions.each do |d, n|
  n = n.to_i
  coords += case d
  when 'U'
    (coords.last[0]-1).downto(coords.last[0]-n).map {[_1, coords.last[1]]}
  when 'D'
    (coords.last[0]+1).upto(coords.last[0]+n).map {[_1, coords.last[1]]}
  when 'L'
    (coords.last[1]-1).downto(coords.last[1]-n).map {[coords.last[0], _1]}
  when 'R'
    (coords.last[1]+1).upto(coords.last[1]+n).map {[coords.last[0], _1]}
  end
end

# Now move the origin so that 0,0 is in the top left
delta_y = coords.map {_1[0]}.min
delta_x = coords.map {_1[1]}.min
coords.map! {|y,x| [y-delta_y, x-delta_x]}

# New max and min are the size of the matrix we need
m = Matrix.build(coords.map {_1[0]}.max+1, coords.map {_1[1]}.max+1) { '.' }
coords.each {|y,x| m[y,x] = '#'}

# Find all the contiguous areas
areas = {}
area_n = -1
m.each_with_index do |c,y,x|
  if c == '.'
    # Check to see if any of its neighbours are already in one of the areas
    found = [[y-1,x],[y+1,x],[y,x-1],[y,x+1]].map {areas[_1]}.compact.uniq
    case found.length
    when 0
      areas[[y,x]] = (area_n += 1)
    when 1
      areas[[y,x]] = found[0]
    else
      # ok - two or more areas are actually 1 area - merge them
      canon = found.shift
      areas[[y,x]] = canon
      areas.transform_values! {|v| found.include?(v) ? canon : v}
    end
  end
end
# Delete the contiguous areas that touch the edges
0.upto(m.column_size) do |x|
  to_delete = [areas[[0,x]], areas[[m.row_size-1,x]]].compact
  to_delete.each {|td| areas.delete_if {|k,v| v == td}}
end
0.upto(m.row_size) do |y|
  to_delete = [areas[[y,0]], areas[[y,m.column_size-1]]]
  to_delete.each {|td| areas.delete_if {|k,v| v == td}}
end

# Label the matrix
areas.each {|(y,x), n| m[y,x] = '#' }

puts m.to_a.map(&:join).join("\n")
p m.count {_1 == '#'}