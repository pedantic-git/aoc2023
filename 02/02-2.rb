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

  def power
    %i[red green blue].map {rounds.map(&_1).max}.reduce(:*)
  end
end

games = ARGF.map {Game.new(_1)}
p games.sum(&:power)

