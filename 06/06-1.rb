#!/usr/bin/env ruby

# Formula for how far it travels for press p in time t is:
# (t-p)*p

# Assuming a record r we need to find all values for which:
# (t-p)*p > r

# The numbers are small at this stage so it might be easiest to brute force it

def n_successes(t,r)
  1.upto(t).select {(t-_1)*_1 > r}.length
end

times = ARGF.readline.scan(/\d+/).map(&:to_i)
records = ARGF.readline.scan(/\d+/).map(&:to_i)

p times.zip(records).map {n_successes _1, _2}.reduce(:*)
