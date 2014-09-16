#!/usr/bin/env ruby
$:.unshift File.join( File.dirname( __FILE__ ), '../lib')

# An instrument that receives note on messages and prints them to the console

require "midi-instrument"

class Instrument

  include MIDIInstrument::Listen

  def initialize(midi_inputs)
    listen_for_midi(midi_inputs)
  end

end

input = UniMIDI::Input.gets

inst = Instrument.new(input)

inst.receive_midi(:class => MIDIMessage::NoteOn) { |event| p event[:message].name }

inst.midi_listener.join
