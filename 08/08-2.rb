#!/usr/bin/env ruby

directions = ARGF.readline.chomp.chars
ARGF.readline # blank line
map = ARGF.inject({}) {/(\w+) = \((\w+), (\w+)\)/ =~ _2; _1.tap {|h| h[$1] = [$2,$3]}}

# This is the algorithm for solving it the "normal" way - as in the example.
# Of course, it runs for a really long time so it will need optimizing

loc = map.keys.select {_1.end_with? 'A'}
steps = 0
queue = []
until loc.all? {_1.end_with? 'Z'}
  queue = directions.dup if queue.empty?
  dir = queue.shift
  loc.map! { map[_1][dir == 'R' ? 1:0] }
  p loc
  steps += 1
end

p steps

