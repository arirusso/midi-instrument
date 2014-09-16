module MIDIInstrument

  module Message

    extend self

    DefaultChannel = 0
    DefaultVelocity = 100

    def to_messages(*args)
      data = [args.dup].flatten
      if data.all? { |item| item.kind_of?(String) }
        Message.to_note_on(*data) # string note names
      elsif data.all? { |item| item.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/) }
        data # messages
      end
    end

    def to_bytes(*args)
      data = [args.dup].flatten
      messages = if data.all? { |item| item.kind_of?(String) }
        Message.to_note_on(*data) # string note names
      elsif data.all? { |item| item.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/) }
        data # messages
      end
      if messages.nil?
        data # array of hex numbers
      else
        messages.map(&:to_bytes).flatten
      end
    end

    # Takes a single note, multiple note args or an array of notes
    def to_note_on(*args)
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
      channel = options[:default_channel] || DefaultChannel
      velocity = options[:default_velocity] || DefaultVelocity
      MIDIMessage::NoteOn[string].new(channel, velocity)
    end

  end

end

