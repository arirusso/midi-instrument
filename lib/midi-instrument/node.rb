module MIDIInstrument

  # Can listen for and send MIDI messages
  class Node

    include API

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

    def receive_channel
      @input.channel
    end
    alias_method :rx_channel, :receive_channel

    def receive_channel=(channel)
      @input.channel = channel
    end
    alias_method :rx_channel=, :receive_channel=

    def transmit_channel
      @output.channel
    end
    alias_method :tx_channel, :transmit_channel

    def transmit_channel=(channel)
      @output.channel = channel
    end
    alias_method :tx_channel=, :transmit_channel=

  end

end

