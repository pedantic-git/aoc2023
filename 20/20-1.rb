#!/usr/bin/env ruby

require 'pp'

class Module
  attr_reader :destinations
  def initialize(destinations)
    @destinations = destinations
  end

  def inspect
    "#<#{self.class} d=#{destinations.join(',')}>"
  end

  # By default, just echo the pulse to all the destinations
  def receive(from, pulse, network)
    network.pulse! pulse, destinations
  end
end

class Conjunction < Module
  attr_reader :origins
  def initialize(destinations)
    super
    @origins = {}
  end

  def inspect
    "#<#{self.class} o=#{origins.map {|kv| kv.join(':')}.join(',')} d=#{destinations.join(',')}>"
  end
end

class FlipFlop < Module
  attr_accessor :state
  def initialize(destinations)
    super
    self.state = :off
  end

  def inspect
    "#<#{self.class} #{state} d=#{destinations.join(',')}>"
  end
end

class Network
  attr_reader :modules
  attr_accessor :low_pulses, :high_pulses
  def initialize(schematics)
    @modules = {}
    @low_pulses = @high_pulses = 0
    schematics.each {load_module _1}
    backfill_origins
  end

  def pulse!(pulse, module)
    # FIXME
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
    modules[name] = kls.new(dests)
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
pp n
