#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# An instrument that receives note on messages and prints them to the console

require "midi-instrument"

class Instrument

  attr_reader :midi

  def initialize
    @midi = MIDIInstrument::Node.new
  end

end

input = UniMIDI::Input.gets

inst = Instrument.new

inst.midi.inputs << input

inst.midi.receive(:class => MIDIMessage::NoteOn) { |event| puts event[:message].name }

inst.midi.listener << "A1" # Add messages manually

inst.midi.listener.join # Wait for input from the MIDI device
