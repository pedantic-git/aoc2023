#!/usr/bin/env ruby

require 'matrix'

def rock_score(m, y, x)
  # Find the first cubic rock heading upwards
  rock = (y-1).downto(0).find {|yq| m[yq,x] == '#'} || -1
  # Find the circles between there and us
  circles = (y-1).downto(rock+1).count {|yq| m[yq,x] == 'O'}
  m.column_size - rock - 1 - circles
end

platform = Matrix[*ARGF.map {_1.chomp.chars}]

final_score = 0
platform.each_with_index do |c,y,x|
  if c == 'O'
    final_score += rock_score(platform, y, x)
  end
end
p final_score
