module MIDISequencer

  module Emit

    def emit_midi(output, data)
      messages = [data].flatten.select { |item| item.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/) }
      bytes = messages.map(&:to_bytes).flatten
      output.puts_bytes(*bytes)
    end

  end

end
