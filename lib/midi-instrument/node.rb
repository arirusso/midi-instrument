module MIDIInstrument

  # Can listen for and send MIDI messages
  class Node

    attr_reader :input, :output

    # @param [Hash] options
    # @option options [Array<UniMIDI::Input>, UniMIDI::Input] :sources Inputs to listen for MIDI on
    def initialize(options = {})
      @input = Input.new(options)
      @output = Output.new
    end

    def inputs
      @input.devices
    end

    def outputs
      @output.devices
    end

  end

end

