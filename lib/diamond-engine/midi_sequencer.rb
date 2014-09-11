module DiamondEngine

  class MIDISequencer

    include SequencerAPI::Clock
    include SequencerAPI::Emitter
    include SequencerAPI::Events
    include SequencerAPI::State
    extend Forwardable

    def_delegators :sequencer, :events, :state
    def_delegators :clock, :sync, :sync?

    attr_reader :emitter, :clock, :sequencer

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @option options [Array<UniMIDI::Output>, UniMIDI::Output] :midi_outputs MIDI output device(s)
    # @option options [Array<UniMIDI::Output>, Boolean, UniMIDI::Output] :midi_clock_output If TrueClass, sends clock to :midi, 
    #                                                                    otherwise to the specified devices
    def initialize(tempo_or_input, options = {}, &block)   
      @components = {}
      output_devices = [options[:midi_outputs]].flatten

      clock_options = options.dup
      clock_options[:outputs] = output_devices if !!options[:midi_clock_output]

      @emitter = MIDIEmitter.new(output_devices)
      @sequencer = Sequencer.new(options)
      @clock = Clock.new(tempo_or_input, clock_options, &block)
    end

    # toggle start/stop
    def toggle_start
      running? ? stop : start
    end

    def running=(val)
      val ? start : stop
    end

    # start the clock
    def start(options = {})     
      @clock.start
      true
    end

    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop(options = {})
      @sequencer.stop
      @clock.stop
      true            
    end

    # add a destination for midi data
    def add_midi_destinations(destinations)
      @emitter.add_destinations(destinations)
      @emitter.add_clock_destinations(destinations, @clock) if midi_clock_output?
    end
    alias_method :add_midi_destination, :add_midi_destinations

    # remove a destination for midi data
    def remove_midi_destinations(destinations)
      @emitter.remove_destinations(destinations)      
      @emitter.remove_clock_destinations(destinations, @clock) if midi_clock_output?
    end
    alias_method :remove_midi_destination, :remove_midi_destinations

  end

end
