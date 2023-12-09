#!/usr/bin/env ruby

def extrapolate(arr)
  [arr].tap do |rows|
    # First, find all the rows
    until rows.last.all?(&:zero?)
      rows << rows.last.each_cons(2).map {_2-_1}
    end
    # Then extrapolate from the bottom row upwards
    rows.last.unshift 0
    (rows.length - 2).downto(0) {rows[_1].unshift(rows[_1][0] - rows[_1+1][0])}
  end.first.first
end

histories = ARGF.map {_1.split(' ').map(&:to_i)}
p histories.map {extrapolate _1}.sum
