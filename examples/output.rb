#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# This example loops through sending a batch of MIDI messages ten times to the user selected output 

require "midi-instrument"

class Instrument

  attr_reader :midi

  def initialize
    @midi = MIDIInstrument::Node.new
  end

end

output = UniMIDI::Output.gets

instrument = Instrument.new

instrument.midi.outputs << output

instrument.midi.puts("A4")
