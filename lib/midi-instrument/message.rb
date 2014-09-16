module MIDIInstrument

  # Helper for converting MIDI messages
  module Message

    extend self

    # @param [Array<MIDIMessage>, Array<String>, MIDIMessage, *MIDIMessage, String] args
    # @return [Array<MIDIMessage>]
    def to_messages(*args)
      data = [args.dup].flatten
      if data.all? { |item| item.kind_of?(String) }
        Message.to_note_ons(*data) # string note names
      elsif data.all? { |item| item.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/) }
        data # messages
      end
    end

    # @param [Array<Fixnum>, Array<MIDIMessage>, Array<String>, MIDIMessage, *MIDIMessage, String] args
    # @return [Array<Fixnum>]
    def to_bytes(*args)
      data = [args.dup].flatten
      messages = if data.all? { |item| item.kind_of?(String) }
        Message.to_note_ons(*data) # string note names
      elsif data.all? { |item| item.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/) }
        data # messages
      end
      if messages.nil?
        data # array of hex numbers
      else
        messages.map(&:to_bytes).flatten
      end
    end

    # @param [*MIDIMessage::NoteOn, *String] args
    # @return [Array<MIDIMessage::NoteOn>]
    def to_note_ons(*args)
      notes = [args.dup].flatten
      options = notes.last.kind_of?(Hash) ? notes.pop : {}
      notes.map do |note|
        case note
        when String then string_to_note_on(note, options)
        when MIDIMessage::NoteOn then note
        end
      end
    end

    private

    def string_to_note_on(string, options = {})
      channel = options.fetch(:default_channel, 0)
      velocity = options.fetch(:default_velocity, 100)
      MIDIMessage::NoteOn[string].new(channel, velocity)
    end

  end

end

