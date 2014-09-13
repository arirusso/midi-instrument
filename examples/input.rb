#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# This example loops through sending a batch of MIDI messages ten times to the user selected output 

require "midi-sequencer"

input = UniMIDI::Input.gets

sequence = [1,2,3,4]
sequencer = MIDISequencer.new

listener = MIDISequencer::Listener.new(sequencer, input)
listener.receive(:class => MIDIMessage::NoteOn) { |m| p m }

clock = Sequencer::Clock.new(120)
clock.event.tick { sequencer.exec(sequence) }

sequencer.event.stop { clock.stop }

clock.start(:focus => true)

