module MIDISequencer

  class Core

    extend Forwardable

    attr_reader :core
    def_delegators :@core, :event, :exec, :trigger

    def initialize(&block)   
      @core = Sequencer.new
    end

    def emit(output, data)
      messages = [data].flatten.select { |item| item.class.name.match(/\AMIDIMessage::[a-zA-Z]+\z/) }
      bytes = messages.map(&:to_bytes).flatten
      output.puts_bytes(*bytes)
    end

  end

  def self.new(&block)
    Core.new(&block)
  end

end
