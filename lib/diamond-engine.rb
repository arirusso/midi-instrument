
# Diamond Engine
# Common functionality for music instruments and sequencers in Ruby
# (c)2011-2014 Ari Russo
# Licensed under the Apache 2.0 License
# 

# libs
require "forwardable"
require "midi-fx"
require "midi-message"
require "topaz"
require "unimidi"

# modules
require "diamond-engine/receives_midi"
require "diamond-engine/sequencer_internal_callbacks"
require "diamond-engine/sequencer_user_callbacks"
require "diamond-engine/syncable"

# classes
require "diamond-engine/event/note"
require "diamond-engine/midi_emitter"
require "diamond-engine/midi_listener"
require "diamond-engine/midi_sequencer"
require "diamond-engine/process_chain"
require "diamond-engine/sequencer_clock"
require "diamond-engine/sequencer_state"
require "diamond-engine/sync"

module DiamondEngine
  
  VERSION = "0.3.5"
  
end
