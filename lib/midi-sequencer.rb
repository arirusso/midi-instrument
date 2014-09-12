#
# MIDI Sequencer
# Core functionality for sequencers
#
# (c)2011-2014 Ari Russo
# Licensed under Apache 2.0
# 

# libs
require "forwardable"
require "midi-fx"
require "midi-message"
require "scale"
require "topaz"
require "unimidi"

# modules
require "midi-sequencer/emits_midi"
require "midi-sequencer/receives_midi"
require "midi-sequencer/syncable"

# classes
require "midi-sequencer/clock"
require "midi-sequencer/event"
require "midi-sequencer/event_trigger"
require "midi-sequencer/midi_emitter"
require "midi-sequencer/midi_listener"
require "midi-sequencer/midi_sequencer"
require "midi-sequencer/sequencer"
require "midi-sequencer/sequencer_state"
require "midi-sequencer/sync"

module MIDISequencer
  
  VERSION = "0.3.5"
  
end
