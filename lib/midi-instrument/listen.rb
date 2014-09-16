module MIDIInstrument
  
  module Listen

    def self.included(base)
      base.send(:attr_reader, :midi_listener)
    end

    private

    def initialize_midi_listener(sources, options = {})
      @midi_listener = Listener.new(self, sources, :map => options[:midi_map])
    end

  end
  
end
