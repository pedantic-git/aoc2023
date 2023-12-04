#!/usr/bin/env ruby

p ARGF.map {/: (.*) \| (.*)/.match(_1).captures.map {|ns|ns.split(' ').map(&:to_i)}.reduce(:&).then {|w| w.empty? ? 0 : 2**(w.length-1)}}.sum
