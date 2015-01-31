#
# MIDI Instrument
# Core MIDI Instrument Functionality
#
# (c)2011-2014 Ari Russo
# Licensed under Apache 2.0
#

# libs
require "forwardable"
require "midi-eye"
require "midi-fx"
require "midi-message"
require "unimidi"

# modules
require "midi-instrument/api"
require "midi-instrument/device"
require "midi-instrument/message"

# classes
require "midi-instrument/input"
require "midi-instrument/listener"
require "midi-instrument/node"
require "midi-instrument/note_event"
require "midi-instrument/output"

module MIDIInstrument

  VERSION = "0.4.6"

end
