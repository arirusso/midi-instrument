#!/usr/bin/env ruby
#
# Common sequencer functionality
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 
require "forwardable"

# modules
require "inst/event_sequencer"
require "inst/midi_channel_filter"
require "inst/midi_emitter"
require "inst/midi_receiver"
require "inst/syncable"

# classes
require "inst/midi_note_event"

module Inst
  
  VERSION = "0.0.1"
  
end
