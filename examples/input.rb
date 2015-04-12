#!/usr/bin/env ruby
$:.unshift(File.join("..", "lib"))

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

notes = Hash.new {|h,k| h[k] = [] }
last = nil

inst.midi.input.receive(:class => MIDIMessage::NoteOn) do |event|
  notes[event[:timestamp]] << event[:message].name
  if last != event[:timestamp]
    unless last.nil?
      log = notes[last].count > 1 ? "chord: #{notes[last].join(', ')}" : "notes: #{notes[last][0]}"
      p log
    end
    last = event[:timestamp]
  end
end

inst.midi.input << "A0" # Add messages manually

inst.midi.input.join # Wait for input from the MIDI device
