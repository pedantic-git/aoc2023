#!/usr/bin/env ruby

require 'pp'

class Module
  attr_reader :name, :destinations
  def initialize(name, destinations)
    @name = name
    @destinations = destinations
  end

  def inspect
    "#<#{self.class} d=#{destinations.join(',')}>"
  end

  def receive(pulse)
    destinations.map {Pulse.new self.name, _1, pulse.type}
  end
end

class Conjunction < Module
  attr_reader :origins
  def initialize(name, destinations)
    super
    @origins = {}
  end

  def inspect
    "#<#{self.class} o=#{origins.map {|kv| kv.join(':')}.join(',')} d=#{destinations.join(',')}>"
  end

  def receive(pulse)
    origins[pulse.origin] = pulse.type
    if origins.values.uniq == %i[high]
      destinations.map {Pulse.new self.name, _1, :low}
    else
      destinations.map {Pulse.new self.name, _1, :high}
    end
  end
end

class FlipFlop < Module
  attr_accessor :state
  def initialize(name, destinations)
    super
    self.state = :off
  end

  def inspect
    "#<#{self.class} #{state} d=#{destinations.join(',')}>"
  end

  def receive(pulse)
    if pulse.type == :high
      []
    elsif state == :off
      self.state = :on
      destinations.map {Pulse.new self.name, _1, :high}
    else
      self.state = :off
      destinations.map {Pulse.new self.name, _1, :low}
    end
  end
end

Pulse = Struct.new(:origin, :destination, :type)

class Network
  attr_reader :modules
  attr_accessor :queue, :low_pulses, :high_pulses, :runs
  def initialize(schematics)
    @modules = {}
    @low_pulses = @high_pulses = 0
    @queue = []
    @runs = 0
    schematics.each {load_module _1}
    backfill_origins
  end

  def start!
    self.runs += 1
    pulse! Pulse.new(nil, 'broadcaster', :low)
  end

  def pulse!(pulse)
    puts runs if pulse.origin == "dp" && pulse.type == :high
    if pulse.type == :low
      self.low_pulses += 1
    else
      self.high_pulses += 1
    end
    self.queue += modules[pulse.destination]&.receive(pulse) || []
    queue.shift&.then {pulse! _1}
  end

  private

  def load_module(schematic)
    kls, name, dests = /([%&])?(\w+) -> (.*)/.match(schematic).captures
    dests = dests.split(', ')
    kls = case kls
    when '&'
      Conjunction
    when '%'
      FlipFlop
    else
      Module
    end
    modules[name] = kls.new(name, dests)
  end

  # Add the origins to the conjunction modules
  def backfill_origins
    modules.each do |name, m|
      m.destinations.each do |d|
        if modules[d].is_a? Conjunction
          modules[d].origins[name] = :low
        end
      end
    end
  end

end

n = Network.new(ARGF)
#pp n
1.upto(1000000) do |i|
  #puts "\e[H\e[2J#{i}"
  #puts i
  n.start!
  #pp n
end

# To solve this I ran it with the 4 inputs to the final conjunction,
# noted down their periods and then found the lcm of them.

# dh 3877
# qd 4001
# bb 3907
# dp 4027

