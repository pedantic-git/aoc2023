#!/usr/bin/env ruby

def parse_maps(io)
  # levels are always in order in the input file so we can just use an integer
  level = 0
  io.inject({}) do |h, l|
    case l
    when /map/
      level += 1
      h[level] = {}
    when /(\d+) (\d+) (\d+)/
      h[level][$2.to_i .. $2.to_i-1+$3.to_i] = $1.to_i-$2.to_i
    end
    h
  end
end

# Given a seed, process it all the way through levels 1..7
def process_seed(maps, seed)
  1.upto(7) do |level|
    maps[level].each do |range, offset|
      if range.cover? seed
        seed += offset
        break
      end
    end
  end
  seed
end

seeds = /seeds: (.*)/.match(ARGF.readline)[1].split(' ').map(&:to_i)
maps = parse_maps(ARGF)

ranges = seeds.each_slice(2).map {|s,l| s..s-1+l}
lowest = Float::INFINITY

ranges.each do |r|
  p "Starting range #{r}"
  r.each.with_index do |s,i|
    puts "." if i % 1000000 == 0
    loc = process_seed(maps, s)
    if loc < lowest
      lowest = loc
      p "New lowest: #{lowest}"
    end
  end
end
