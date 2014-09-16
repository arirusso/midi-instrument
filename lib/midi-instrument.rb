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
require "midi-fx"
require "midi-message"
require "scale"
require "unimidi"

# modules
require "midi-instrument/message"
require "midi-instrument/listen"
require "midi-instrument/emit"

# classes
require "midi-instrument/listener"
require "midi-instrument/node"
require "midi-instrument/note_event"

module MIDIInstrument
  
  VERSION = "0.3.5"
  
end
