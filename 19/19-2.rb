#!/usr/bin/env ruby

require 'pp'

Part = Struct.new(:x, :m, :a, :s)

# A rule is a _series_ of conditions that must all be true and a destination
class Rule
  attr_accessor :conditions, :destination

  def initialize(conditions, destination)
    @conditions = conditions
    @destination = destination
  end

  def self.from_s(s)
    conditions = []
    /^(?:(\w+)([<>])(\d+):)?(\w+)$/.match(s)
    destination = $4
    if $1
      conditions << {l: $1, op: $2, v: $3.to_i}
    end
    new conditions, destination
  end
end

class Machine
  attr_accessor :workflows
  def initialize(a)
    @workflows = a.inject({}) do |h,s|
      /^(\w+)\{(.*)\}$/.match(s)
      h.update($1 => $2.split(',').map {Rule.from_s _1})
    end
  end

  # Fold the 'in' workflow until it can't be folded any more
  def fold!
    until workflows['in'].map(&:destination).sort.uniq == %w[A R]
      fold_workflow! 'in'
    end
  end

  # Fold the given workflow once by following each rule to its destination and
  # replacing it with the appropriate rules from there
  def fold_workflow!(label)
    workflows[label] = workflows[label].flat_map do |rule|
      if rule.destination == 'A' || rule.destination == 'R'
        rule
      else
        workflows[rule.destination].map do |drule|
          Rule.new(rule.conditions + drule.conditions, drule.destination)
        end
      end
    end
  end

  # Convert a workflow to a string
  def workflow_to_s(w)
    workflows[w].map do |rule|
      ands = rule.conditions.map {|c| "#{c[:l]} #{c[:op]} #{c[:v]}"}.join(' && ')
      "#{ands} => #{rule.destination}"
    end.join("\n")
  end

  # Test a part
  def test(part)
    workflows['in'].each do |rule|
      if rule.conditions.all? {|c| part.public_send(c[:l]).public_send(c[:op], c[:v])}
        return rule.destination
      end
    end
  end
end

machine = Machine.new(ARGF.grep /^\w+\{/)
machine.fold!

accepted = 0
1.upto(4000) do |x|
  p "x: #{x}"
  1.upto(4000) do |m|
    p "m: #{m}"
    1.upto(4000) do |a|
      p "a: #{a}"
      1.upto(4000) do |s|
        if machine.test(Part.new(x: x, m: m, a: a, s: s)) == 'A'
          accepted += 1
        end
      end
    end
  end
end

puts accepted

