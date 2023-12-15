#!/usr/bin/env ruby

Lens = Struct.new(:label, :fl)

class LensBox
  attr_accessor :boxes

  def initialize
    @boxes = {}
  end

  def instruct!(i)
    label, instruction, fl = /(\w+)([-=])(\d*)/.match(i).captures
    box = hash(label)
    boxes[box] ||= []
    case instruction
    when "-"
      boxes[box].reject! { _1.label == label }
    when "="
      if i = boxes[box].index {_1.label == label }
        boxes[box][i].fl = fl.to_i
      else
        boxes[box] << Lens.new(label, fl.to_i)
      end
    end
  end

  def focusing_power
    boxes.flat_map do |box, lenses|
      lenses.map.with_index {|l, i| (box+1) * l.fl * (i+1)}
    end.sum
  end

  private

  def hash(str)
    str.chars.inject(0) {|a,n| (a+n.ord) * 17 % 256}
  end

end

lb = LensBox.new
ARGF.read.chomp.split(",").each {lb.instruct! _1}
p lb.focusing_power