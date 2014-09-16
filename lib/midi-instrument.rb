#
# MIDI Instrument
# MIDI Instrument modules
#
# (c)2011-2014 Ari Russo
# Licensed under Apache 2.0
# 

# libs
require "forwardable"
require "midi-eye"
require "midi-message"
require "scale"
require "sequencer"
require "unimidi"

# classes
require "midi-instrument/emit"
require "midi-instrument/listen"
require "midi-instrument/listener"
require "midi-instrument/note_event"

module MIDIInstrument
  
  VERSION = "0.3.5"
  
end
