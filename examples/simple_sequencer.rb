#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# This example is a sequencer that loops through the array
# ten times
#

require "diamond-engine"

loop_counter = 0
sequence = [1,2,3,4]

sequencer = DiamondEngine::Sequencer.new

sequencer.event.perform do |data, state| 
  puts data
  loop_counter += 1 if state.pointer == 3
end

clock = DiamondEngine::Clock.new(120)

clock.event.tick do
  sequencer.perform(sequence) && sequencer.step(sequence)
end

sequencer.trigger.stop { |data| loop_counter == 10 }

sequencer.event.stop { clock.stop }

clock.start(:focus => true)
