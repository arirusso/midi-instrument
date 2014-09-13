#
# MIDI Sequencer
# Core MIDI sequencer functionality
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
require "midi-sequencer/core"
require "midi-sequencer/listener"
require "midi-sequencer/note_event"

module MIDISequencer
  
  VERSION = "0.3.5"
  
end
