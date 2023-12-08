#!/usr/bin/env ruby

directions = ARGF.readline.chomp.chars
ARGF.readline # blank line
map = ARGF.inject({}) {/(\w+) = \((\w+), (\w+)\)/ =~ _2; _1.tap {|h| h[$1] = [$2,$3]}}

loc = map.keys.select {_1.end_with? 'A'}

# Each location has a "period" that is a static number of steps - find it
def find_period(map, directions, l)
  steps = 0
  queue = []
  loop do
    queue = directions.dup if queue.empty?
    return steps if l.end_with? 'Z'
    l = map[l][queue.shift == 'R' ? 1:0]
    steps += 1
  end
end

periods = loc.map {find_period map, directions, _1}

# The lcm of these periods is the first time they all intersect
p periods.reduce(:lcm)


