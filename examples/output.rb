#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# Sends MIDI notes to an output 

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

%w{A3 C4 E4 A4 C5 E5 A6}.each do |note|
  instrument.midi.output << note
  sleep(0.2)
end
