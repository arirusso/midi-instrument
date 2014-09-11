#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

require "diamond-engine"

sequence = [1,2,3,4]
sequencer = DiamondEngine::Sequencer.new { |data| p data }

clock = DiamondEngine::Clock.new(120) do
  sequencer.perform(sequence) && sequencer.step(sequence)
end

sequencer.event_trigger.stop_when do |data|
  data == 4
end
sequencer.event.stop do
  clock.stop
end

clock.start(:focus => true)
