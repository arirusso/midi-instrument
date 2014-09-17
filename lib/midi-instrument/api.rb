module MIDIInstrument

  # Adds convenience methods when included by Node
  module API

    # Input convenience methods
    module Input

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, :@input, :omni_on)
      end

      # MIDI input devices
      # @return [Array<UniMIDI::Input>]
      def inputs
        @input.devices
      end

      # MIDI channel messages will only be acknowledged if they have this optional specified channel
      # @return [Fixnum, nil]
      def receive_channel
        @input.channel
      end
      alias_method :rx_channel, :receive_channel

      # Set the receive channel
      # @return [Fixnum, nil]
      def receive_channel=(channel)
        @input.channel = channel
      end
      alias_method :rx_channel=, :receive_channel=

    end

    # Output convenience methods
    module Output

      def self.included(base)
        base.send(:extend, Forwardable)
        base.send(:def_delegators, :@output, :mute, :toggle_mute, :mute=, :muted?, :mute?)
      end

      # MIDI output devices
      # @return [Array<UniMIDI::Output>]
      def outputs
        @output.devices
      end

      # MIDI channel messages will be optionally forced to have this channel when outputted
      # @return [Fixnum, nil]
      def transmit_channel
        @output.channel
      end
      alias_method :tx_channel, :transmit_channel

      # Set an optional MIDI channel to force channel notes into when outputted
      # @return [Fixnum, nil]
      def transmit_channel=(channel)
        @output.channel = channel
      end
      alias_method :tx_channel=, :transmit_channel=

    end

  end

end

