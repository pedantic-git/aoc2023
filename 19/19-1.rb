#!/usr/bin/env ruby

Part = Struct.new(:x, :m, :a, :s) do
  def value
    x+m+a+s
  end
end

class Rule
  attr_accessor :rating, :op, :value, :destination

  # Given a string like 's>2770:qs'
  def initialize(s)
    @rating, @op, @value, @destination = /^(?:([xmas])([<>])(\d+):)?(\w+)$/.match(s).captures
    @value = @value.to_i
  end
end

class Machine

  attr_accessor :workflows

  # Given an array of workflow strings
  def initialize(a)
    @workflows = a.inject({}) do |h,s|
      /^(\w+)\{(.*)\}$/.match(s)
      h.update($1 => $2.split(',').map {Rule.new _1})
    end
  end

  # Test a part - returns 'A' or 'R'
  def test(part)
    w = 'in'
    while w != 'A' && w != 'R'
      w = next_workflow(w, part)
    end
    w
  end

  private

  # Get the next workflow for the given workflow and part
  def next_workflow(w, part)
    workflows[w].each do |r|
      return r.destination if r.op.nil?
      return r.destination if part.public_send(r.rating).public_send(r.op, r.value)
    end
    fail "Failed to find next workflow for #{w} / #{part.inspect}"
  end
end

# Find the two arrays of strings in ARGF
ws = []
while l = ARGF.gets
  break if l !~ /\w/
  ws << l
end
parts = []
while l = ARGF.gets
  parts << Part.new(*/x=(\d+),m=(\d+),a=(\d+),s=(\d+)/.match(l).captures.map(&:to_i))
end

m = Machine.new(ws)
p parts.select {m.test(_1) == 'A'}.map(&:value).sum

