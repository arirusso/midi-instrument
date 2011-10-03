#!/usr/bin/env ruby
#
# Diamond Engine
# Common functionality for music instruments and sequencers in Ruby
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "forwardable"

require "osc-ruby"
require "osc-ruby/em_server"
require "midi-message"
require "topaz"
require "unimidi"

# modules
require "diamond-engine/receives_osc"
require "diamond-engine/sequencer_internal_callbacks"
require "diamond-engine/sequencer_user_callbacks"
require "diamond-engine/syncable"

# classes
require "diamond-engine/midi_emitter"
require "diamond-engine/midi_sequencer"
require "diamond-engine/osc_server"
require "diamond-engine/process_chain"
require "diamond-engine/sequencer_clock"
require "diamond-engine/sequencer_state"
require "diamond-engine/sync"

module DiamondEngine
  
  VERSION = "0.1.1"
  
end
