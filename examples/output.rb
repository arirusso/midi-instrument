#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# This example loops through sending a batch of MIDI messages ten times to the user selected output 

require "midi-sequencer"
input = UniMIDI::Input.gets
output = UniMIDI::Output.gets

sequence = %w{A1 A2 A3 A4}.map { |n| MIDIMessage::NoteOn[n].new(0, 100) }
sequencer = MIDISequencer.new

listener = MIDISequencer::Listener.new(sequencer, input)

clock = Sequencer::Clock.new(120)
clock.event.tick { sequencer.exec(sequence) }

sequencer.trigger.stop { |state| state.repeat == 10 }
sequencer.event.perform { |state, data| sequencer.emit(output, data) }
sequencer.event.stop { clock.stop }

clock.start(:focus => true)
