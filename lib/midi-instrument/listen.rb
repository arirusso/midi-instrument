module MIDIInstrument
  
  # Enable a node to listen for MIDI messages on a MIDI input
  module Listen

    def self.included(base)
      base.send(:attr_reader, :inputs, :listener, :receive_channel)
      base.send(:alias_method, :rx_channel, :receive_channel)
    end

    # Add a MIDI input callback
    # @param [Hash] match Matching spec
    # @param [Proc] callback
    # @return [Boolean]
    def receive(match = {}, &callback)
      listener.receive(match) do |event|
        event = filter_event(event)
        yield(event)
      end
      self
    end

    def add_messages(*messages)
      messages = Message.to_messages([messages].flatten)
      messages = messages.map { |message| filter_message(message) }.compact
      listener.add(messages) unless messages.empty?
      messages
    end

    # Set the listener to acknowledge notes on all channels
    # @return [Boolean]
    def omni_on
      @input_filter = nil
      @receive_channel = nil
      true
    end

    # Set the listener to only acknowledge notes from a specific channel
    # @return [Boolean]
    def receive_channel=(channel)
      @input_filter = channel.nil? ? channel : MIDIFX::Filter.new(:channel, channel, :name => :input_channel)
      @receive_channel = channel
      true
    end

    # Replace the inputs with the given inputs
    # @param [Array<UniMIDI::Inputs>] inputs
    # @return [InputContainer]
    def inputs=(inputs)
      @inputs.clear
      @inputs += inputs
      @inputs
    end

    private

    # @param [Hash] options
    # @option options [Array<UniMIDI::Input>, UniMIDI::Input] :sources
    # @option options [Hash] :input_map
    def initialize_listen(options = {})
      @listener = Listener.new(options[:sources])
      @inputs = InputContainer.new(@listener)
    end

    def filter_event(event)
      if !@input_filter.nil?
        if !(message = filter_message(event[:message])).nil?
          event[:message] = message
          event
        end
      else
        event
      end
    end

    def filter_message(message)
      message = @input_filter.process(message) unless @input_filter.nil?
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

      # Add multiple inputs
      # @param [Array<UniMIDI::Input>] inputs
      # @return [InputContainer]
      def +(inputs)
        result = super
        @listener.add_input(inputs)
        result
      end

      # Add multiple inputs
      # @param [Array<UniMIDI::Input>] inputs
      # @return [InputContainer]
      def concat(inputs)
        result = super
        @listener.add_input(inputs)
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

      # Clear all inputs
      # @return [InputContainer]
      def clear
        @listener.inputs.each { |input| delete(input) }
        super
      end

      # Delete multiple inputs
      # @param [Proc] block
      # @return [InputContainer]
      def delete_if(&block)
        inputs = super
        @listener.remove_input(inputs)
        self
      end

    end

  end
  
end
