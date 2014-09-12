module MIDISequencer 

  module EmitsMIDI

    # add a destination for midi data
    def add_midi_destinations(destinations)
      @emitter.add_destinations(destinations)
    end
    alias_method :add_midi_destination, :add_midi_destinations

    # remove a destination for midi data
    def remove_midi_destinations(destinations)
      @emitter.remove_destinations(destinations)      
    end
    alias_method :remove_midi_destination, :remove_midi_destinations


  end
end
