module MIDISequencer

    # An NoteEvent is a pairing of a MIDI NoteOn and NoteOff message
    # has a length that corresponds to sequencer ticks
    class NoteEvent

      extend Forwardable

      attr_reader :start,
                  :finish,
                  :length
                  
      alias_method :duration, :length

      def_delegators :start, :note
      
      def initialize(start_message, duration, options = {})
        @start = start_message
        @length = duration

        @finish = options[:finish] || start_message.to_note_off
      end

    end
    
  end
  
end
