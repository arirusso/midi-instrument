module MIDIInstrument
  
  # Enable an object to listen for MIDI messages on a MIDI input
  module Listen

    def self.included(base)
      base.send(:attr_reader, :midi_listener)
    end

    def receive_midi(*args, &block)
      @midi_listener.receive(*args, &block)
    end

    private

    # Initialize the object as a MIDI listener
    # @param [Array<UniMIDI::Input>, UniMIDI::Input] sources
    def listen_for_midi(sources, options = {})
      @midi_listener = Listener.new(self, sources, :map => options[:midi_map])
    end

  end
  
end
