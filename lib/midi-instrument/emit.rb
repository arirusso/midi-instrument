module MIDIInstrument

  module Emit

    def self.included(base)
      base.send(:attr_reader, :outputs)
    end

    def puts(*data)
      bytes = Message.to_bytes(*data)
      @outputs.map { |output| output.puts_bytes(*bytes) }
    end

    private

    def initialize_emit
      @outputs = []
    end

  end

end
