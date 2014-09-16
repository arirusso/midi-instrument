module MIDIInstrument

  # An NoteEvent is a pairing of a MIDI NoteOn and NoteOff message.  Its duration can correspond to sequencer ticks
  class NoteEvent

    extend Forwardable

    attr_reader :start,
      :finish,
      :length

    alias_method :duration, :length

    def_delegators :start, :note

    # @param [MIDIMessage::NoteOn] start_message
    # @param [Fixnum] duration
    # @param [Hash] options
    # @option options [MIDIMessage::NoteOff] :finish
    def initialize(start_message, duration, options = {})
      @start = start_message
      @length = duration

      @finish = options[:finish] || start_message.to_note_off
    end

  end

end
