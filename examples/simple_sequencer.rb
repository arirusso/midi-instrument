#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond-engine"

sequence = [1,2,3,4]
sequencer = DiamondEngine::Sequencer.new { |data| p data }

clock = DiamondEngine::Clock.new(120) do
  sequencer.step(sequence) && sequencer.perform(sequence)
end

sequencer.events.stop_when do |data|
  data == 4
end
sequencer.events.stop do
  clock.stop
end

clock.start(:focus => true)
