#!/usr/bin/env ruby

def hash(inst)
  inst.chars.inject(0) {|a,n| (a+n.ord) * 17 % 256}
end

p ARGF.read.chomp.split(",").map {hash _1}.sum
