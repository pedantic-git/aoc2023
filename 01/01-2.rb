#!/usr/bin/env ruby

DIGITS = {
  'one'=>'1', 'two'=>'2', 'three'=>'3', 'four'=>'4', 'five'=>'5', 
  'six'=>'6', 'seven'=>'7', 'eight'=>'8', 'nine'=>'9'
}
CAPT = "(#{DIGITS.keys.join '|'}|\\d)"
def first_and_last_digits(str)
  [/#{CAPT}.*/.match(str)[1], /.*#{CAPT}/.match(str)[1]].map {DIGITS[_1]||_1}.join.to_i
end

p ARGF.map {|l| first_and_last_digits(l)}.reduce(:+)
