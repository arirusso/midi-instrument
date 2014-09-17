module MIDIInstrument

  # Can listen for and send MIDI messages
  class Node

    include API::Input
    include API::Output

    attr_reader :input, :output

    # @param [Hash] options
    # @option options [Array<UniMIDI::Input>, UniMIDI::Input] :sources Inputs to listen for MIDI on
    def initialize(options = {})
      @input = Input.new(options)
      @output = Output.new
    end

  end

end

