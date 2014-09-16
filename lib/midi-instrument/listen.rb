module MIDIInstrument
  
  # Enable an object to listen for MIDI messages on a MIDI input
  module Listen

    def self.included(base)
      base.send(:attr_reader, :inputs, :listener)
    end

    def receive(*args, &block)
      listener.receive(*args, &block)
    end

    private

    # @param [Hash] options
    # @option options [Array<UniMIDI::Input>, UniMIDI::Input] :sources
    # @option options [Hash] :input_map
    def initialize_listen(options = {})
      @listener = Listener.new(self, options[:sources], :map => options[:input_map])
      @inputs = InputContainer.new(@listener)
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

      # Delete an input
      # @param [UniMIDI::Input]
      # @return [UniMIDI::Input]
      def delete(input)
        result = super
        @listener.remove_input(input)
        result
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
