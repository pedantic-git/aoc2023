#!/usr/bin/env ruby

directions = ARGF.readline.chomp.chars
ARGF.readline # blank line
map = ARGF.inject({}) {/(\w+) = \((\w+), (\w+)\)/ =~ _2; _1.tap {|h| h[$1] = [$2,$3]}}

# Old-school this without any functions (higher-order or otherwise)
loc = "AAA"
steps = 0
queue = []
until loc == "ZZZ"
  queue = directions.dup if queue.empty?
  loc = map[loc][queue.shift == 'R' ? 1:0]
  steps += 1
end

p steps

