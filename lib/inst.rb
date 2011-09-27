#!/usr/bin/env ruby
#
# Common sequencer functionality
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 

# libs
require "forwardable"

require "midi-message"
require "topaz"

# modules
require "inst/sequencer_callbacks"
require "inst/syncable"

# classes
require "inst/midi_emitter"
require "inst/midi_sequencer"
require "inst/process_chain"
require "inst/sequencer_clock"
require "inst/sequencer_state"
require "inst/sync_scheme"

module Inst
  
  VERSION = "0.0.1"
  
end
