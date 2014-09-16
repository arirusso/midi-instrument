module MIDIInstrument

  # Can listen for and send MIDI messages
  class Node

    include Emit
    include Listen

    # @param [Hash] options
    # @option options [Array<UniMIDI::Input>, UniMIDI::Input] :sources Inputs to listen for MIDI on
    def initialize(options = {})
      initialize_emit(options)
      initialize_listen(options)
    end

  end

end

