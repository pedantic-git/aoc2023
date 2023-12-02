#!/usr/bin/env ruby

Round = Struct.new(:red,:green,:blue)

class Game
  attr_reader :id, :rounds

  def initialize(line)
    /Game (\d+): (.*)/ =~ line
    @id = $1.to_i
    @rounds = $2&.split('; ').map do |rl|
      Round.new(0,0,0).tap do |round|
        rl.split(', ').each do |cubes|
          /(\d+) (\w+)/ =~ cubes
          round.send(:"#{$2}=", round.send($2.to_sym) + $1.to_i)
        end
      end
    end
  end

  def valid?
    rounds.all? {|r| r.red <= 12 && r.green <= 13 && r.blue <= 14}
  end
end

games = ARGF.map {Game.new(_1)}
valid, invalid = games.partition(&:valid?)

p valid.sum(&:id)
