#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# 

require "midi-sequencer"

input = UniMIDI::Input.gets

sequence = [1,2,3,4]
sequencer = MIDISequencer.new

listener = MIDISequencer::Listener.new(sequencer, input)

listener.receive(:class => MIDIMessage::NoteOn) do |event| 
  sequence[sequencer.state.pointer] = event[:message].note
end

clock = Sequencer::Clock.new(120)
clock.event.tick { sequencer.exec(sequence) }

sequencer.event.perform { |state, data| p sequence }
sequencer.event.stop { clock.stop }

clock.start(:focus => true)

