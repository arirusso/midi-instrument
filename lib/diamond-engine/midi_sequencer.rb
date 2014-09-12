module DiamondEngine

  class MIDISequencer

    include EmitsMIDI
    extend Forwardable

    attr_reader :emitter, :clock, :core
    def_delegators :@core, :toggle_start, :start, :stop, :step, :perform

    def initialize(options = {}, &block)   
      @core = Sequencer.new
      @emitter = MIDIEmitter.new(options[:midi_outputs])
    end

  end

end
