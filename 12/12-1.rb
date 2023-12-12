#!/usr/bin/env ruby

def combinations(pattern, ns)
  expand(pattern).map {counts _1}.count {|o| o == ns}
end

# Given a pattern containing ?s, expand it into all the possible variants
def expand(pattern)
  pattern.chars.map {_1 == '?' ? ['#','.'] : [_1]}.then {|o| o.shift.product(*o)}
end

# Get the numeric counts for the given array of #/.
def counts(arr)
  counts = [0]
  arr.each do |c|
    if c == '#'
      counts[-1] += 1
    else
      counts << 0 unless counts[-1].zero?
    end
  end
  counts.pop if counts[-1].zero?
  counts
end

p ARGF.map {/(\S+) (\S+)/.match(_1).then {combinations($1, $2.split(',').map(&:to_i))}}.sum

