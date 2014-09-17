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
      @channel_filter = nil
    end

    # Add a MIDI input callback
    # @param [Hash] match Matching spec
    # @param [Proc] callback
    # @return [Listen]
    def receive(match = {}, &block)
      if block_given?
        @listener.receive(match) do |event|
          event = filter_event(event)
          yield(event)
        end
      end
      self
    end

    def add(*messages)
      messages = Message.to_messages([messages].flatten)
      messages = messages.map { |message| filter_message(message) }.compact
      @listener.add(*messages) unless messages.empty?
      messages
    end
    alias_method :<<, :add
    
    # Set the listener to acknowledge notes on all channels
    # @return [Boolean]
    def omni
      @channel_filter = nil
      @channel = nil
      true
    end
    alias_method :omni_on, :omni

    # Set the listener to only acknowledge notes from a specific channel
    # @return [Boolean]
    def channel=(channel)
      @channel_filter = channel.nil? ? nil : MIDIFX::Filter.new(:channel, channel, :name => :input_channel)
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

    def filter_event(event)
      if !@channel_filter.nil?
        if !(message = filter_message(event[:message])).nil?
          event[:message] = message
          event
        end
      else
        event
      end
    end

    def filter_message(message)
      message = @channel_filter.process(message) unless @channel_filter.nil?
      message
    end

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
