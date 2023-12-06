#!/usr/bin/env ruby

# Refactor:
# (t-p)*p = r # to exactly meet the record
# tp-p**2 = r
# -p**2 + tp - r = 0 # in the form of a quadratic equation

# Find the two solutions to a quadratic equation a**2x + bx + c = 0
def quadratic(a,b,c)
  discroot = Math.sqrt((b*b - 4*a*c).to_f)
  [(-b+discroot)/(2*a).to_f, (-b-discroot)/(2*a).to_f]
end

# Find the two points on the scale that equal the record r for time t
def solutions(t,r)
  quadratic(-1, t, -r)
end

# Find the number of wins (i.e. whole numbers between the two possible times for
# equalling the record
def n_wins(t,r)
  solns = solutions(t,r)
  # ensure we _beat_ the record, not just equalize
  ((solns.min + 1).floor .. (solns.max - 1).ceil).size
end

time = ARGF.readline.scan(/\d+/).join.to_i
record = ARGF.readline.scan(/\d+/).join.to_i

p n_wins(time, record)
