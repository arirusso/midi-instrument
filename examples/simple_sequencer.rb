#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# This example is a sequencer that loops through the array
# ten times
#

require "diamond-engine"

sequence = [1,2,3,4]
sequencer = DiamondEngine::Sequencer.new

clock = DiamondEngine::Clock.new(120)
clock.event.tick do
  sequencer.perform(sequence) && sequencer.step(sequence)
end

sequencer.trigger.stop { |state| state.repeat == 10 }
sequencer.event.perform { |state, data| puts data }
sequencer.event.stop { clock.stop }

clock.start(:focus => true)
