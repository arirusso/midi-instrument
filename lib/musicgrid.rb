#!/usr/bin/env ruby
#
# Some essential functionality for Ruby music sequencers
# (c)2011 Ari Russo and licensed under the Apache 2.0 License
# 
require "forwardable"

# modules
require "musicgrid/event_sequencer"
require "musicgrid/midi_channel_filter"
require "musicgrid/midi_emitter"
require "musicgrid/midi_receiver"
require "musicgrid/syncable"

# classes
require "musicgrid/midi_note_event"

module MusicGrid
  
  VERSION = "0.0.5"
  
end
