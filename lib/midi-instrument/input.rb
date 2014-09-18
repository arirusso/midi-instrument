module MIDIInstrument
  
  # Enable a node to listen for MIDI messages on a MIDI input
  class Input

    extend Forwardable

    attr_reader :devices, :channel
    def_delegators :@listener, :join

    # @param [Hash] options
    # @option options [Array<UniMIDI::Input>, UniMIDI::Input] :sources
    # @option options [Hash] :input_map
    def initialize(options = {})
      @listener = Listener.new(options[:sources])
      @devices = InputContainer.new(@listener)
      @channel = nil
    end

    # Add a MIDI input callback
    # @param [Hash] match Matching spec
    # @param [Proc] callback
    # @return [Listen]
    def receive(match = {}, &block)
      if block_given?
        @listener.receive(match) { |event| yield(event) }
      end
      self
    end

    # Manually add messages to the input
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] messages
    # @return [Array<MIDIMessage>]
    def add(*messages)
      messages = Message.to_messages([messages].flatten).compact
      @listener.add(*messages) unless messages.empty?
      messages
    end
    alias_method :<<, :add
    
    # Set the listener to acknowledge notes on all channels
    # @return [Boolean]
    def omni
      @channel = nil
      true
    end
    alias_method :omni_on, :omni

    # Specify an input channel
    # @return [Boolean]
    def channel=(channel)
      @channel = channel
      true
    end

    # Replace the devices with the given devices
    # @param [Array<UniMIDI::Inputs>] devices
    # @return [InputContainer]
    def devices=(devices)
      @devices.clear
      @devices += devices
      @devices
    end

    private

    # Container class that handles updating the listener when changes are made
    class InputContainer < Array

      # @param [Listener] listener
      def initialize(listener)
        @listener = listener
      end

      # Add an input
      # @param [UniMIDI::Input] input
      # @return [InputContainer] 
      def <<(input)
        result = super
        @listener.add_input(input)
        result
      end

      # Add multiple devices
      # @param [Array<UniMIDI::Input>] devices
      # @return [InputContainer]
      def +(devices)
        result = super
        @listener.add_input(devices)
        result
      end

      # Add multiple devices
      # @param [Array<UniMIDI::Input>] devices
      # @return [InputContainer]
      def concat(devices)
        result = super
        @listener.add_input(devices)
        result
      end

      # Delete an input
      # @param [UniMIDI::Input]
      # @return [UniMIDI::Input]
      def delete(input)
        result = super
        @listener.remove_input(input)
        result
      end

      # Clear all devices
      # @return [InputContainer]
      def clear
        @listener.inputs.each { |input| delete(input) }
        super
      end

      # Delete multiple devices
      # @param [Proc] block
      # @return [InputContainer]
      def delete_if(&block)
        devices = super
        @listener.remove_input(devices)
        self
      end

    end

  end
  
end
