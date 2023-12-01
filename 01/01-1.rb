#!/usr/bin/env ruby

# We can't use /(\d).*(\d)/ because some strings contain only one digit.
# Using /(\d).*(\d?)/ would work and be a lot faster than #scan but it would require more code
# to wrangle.

p ARGF.map {|l| l.scan(/\d/).then {"#{_1[0]}#{_1[-1]}"}.to_i}.reduce(:+)
