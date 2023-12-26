#!/usr/bin/env ruby

require 'ruby-graphviz'
require 'graphviz/theory'
nodemap = ARGF.inject({}) {|h,l| /(\S{3}): (.*)/.match(l); h[$1] = $2.split; h}

# Delete the links frl-thx / ccp-fvm / llm-lhg that show up clearly on the dot output
nodemap["frl"].delete("thx")
nodemap["thx"].delete("frl")
nodemap["ccp"].delete("fvm")
nodemap["fvm"].delete("ccp")
nodemap["llm"].delete("lhg")
nodemap["lhg"].delete("llm")

g = GraphViz.new(:G, type: :graph)
nodemap.keys.each {g.add_nodes _1}
nodemap.each {|k,v| v.each {|c| g.add_edge k, c}}

# Used this to draw the picture that helped me find the edges to cut
# g.output dot: 'graph.dot'


# Not sure why generating the answer with GraphViz didn't work
# t = GraphViz::Theory.new(g)

# s1 = 0
# t.dfs("thb") { s1 += 1 }
# s2 = 0
# t.dfs("fxr") { s2 += 1 }

# p [g.node_count, s1, s2, s1*s2]

class Node
  @@nodes = {}
  def self.find(name)
    @@nodes[name] ||= Node.new(name)
  end

  attr_accessor :name, :neighbors

  def add_edge(other)
    neighbors << other
    other.neighbors << self
  end

  def group(memo=Set.new)
    memo << self
    (neighbors - memo.to_a).each { _1.group(memo) }
    memo
  end

  private

  def initialize(name)
    @name = name
    @neighbors = Set.new
  end
end

nodemap.each do |name, neighbors|
  node = Node.find(name)
  neighbors.each {|n| node.add_edge(Node.find(n))}
end

s1 = Node.find("thb").group.length
s2 = Node.find("fxr").group.length

p [g.node_count, s1, s2, s1*s2]
