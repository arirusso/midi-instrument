#
# Diamond Engine
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
require "diamond-engine/receives_midi"
require "diamond-engine/sequencer_api"

# classes
require "diamond-engine/event/note"
require "diamond-engine/events"
require "diamond-engine/midi_emitter"
require "diamond-engine/midi_listener"
require "diamond-engine/midi_sequencer"
require "diamond-engine/process_chain"
require "diamond-engine/sequencer_state"
require "diamond-engine/sync"

module DiamondEngine
  
  VERSION = "0.3.5"
  
end
