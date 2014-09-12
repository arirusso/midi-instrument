#
# MIDI Sequencer
# Core functionality for sequencers
#
# (c)2011-2014 Ari Russo
# Licensed under Apache 2.0
# 

# libs
require "forwardable"
require "midi-message"
require "sequencer"
require "topaz"
require "unimidi"

# modules
require "midi-sequencer/emits_midi"
require "midi-sequencer/receives_midi"

# classes
require "midi-sequencer/midi_emitter"
require "midi-sequencer/midi_listener"
require "midi-sequencer/midi_sequencer"
require "midi-sequencer/note_event"

module MIDISequencer
  
  VERSION = "0.3.5"
  
end
