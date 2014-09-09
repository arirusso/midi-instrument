module DiamondEngine

  class MIDISequencer

    include SequencerAPI::Clock
    include SequencerAPI::Emitter
    include SequencerAPI::Events
    include SequencerAPI::State
    include SequencerAPI::Sync

    attr_accessor :midi_clock_output, :sequence, :name
    attr_reader :clock, :events, :output_process, :state
    alias_method :midi_clock_output?, :midi_clock_output

    # @param [Fixnum, UniMIDI::Input] tempo_or_input
    # @param [Hash] options
    # @option options [Array<UniMIDI::Output>, UniMIDI::Output] :midi_outputs MIDI output device(s)
    # @option options [Array<UniMIDI::Output>, Boolean, UniMIDI::Output] :midi_clock_output If TrueClass, sends clock to :midi, 
    #                                                                    otherwise to the specified devices
    def initialize(tempo_or_input, options = {}, &block)          
      output_devices = [options[:midi_outputs]].flatten
      clock_options = get_clock_options(output_devices, options[:midi_clock_output])

      @name = options[:name]
      @sequence = options[:sequence]
      @output_process = ProcessChain.new

      initialize_clock(tempo_or_input, options.fetch(:resolution, 128), clock_options)
      @emitter = MIDIEmitter.new(output_devices)
      @state = SequencerState.new
      @events = Events.new

      edit(&block) unless block.nil?
    end

    # toggle start/stop
    def toggle_start
      running? ? stop : start
    end

    # stops and sends all note offs
    def quiet!
      stop
      cleanup
    end

    # sends all note-offs
    def cleanup
      @emitter.quiet!
    end

    # mute the sequencer 
    def mute
      emit_pending_note_offs
      @emitter.mute
    end

    # open the instrument for editing
    def edit(&block)
      instance_eval(&block)
    end

    def running=(val)
      val ? start : stop
    end

    # start the clock
    def start(options = {})     
      trap "SIGINT", proc { 
        quiet!        
        exit
      }
      @events.start.call(@state) unless @events.start.nil?
      clock_options = {}
      clock_options[:background] = true unless !!options[:focus] || !!options[:foreground]
      @state.start
      @clock.start(clock_options) unless !!options[:suppress_clock]
      true
    end

    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop(options = {})
      @clock.stop rescue false
      @state.stop
      emit_pending_note_offs
      @events.stop.call(@state) unless @events.stop.nil?
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

    protected  

    # send all of the note off messages in the queue
    def emit_pending_note_offs
      messages = @sequence.pending_note_offs
      @emitter.emit(messages) unless messages.empty?
    end

    def tick
      Sync[self].activate_queued(:force_sync_now => @state.pointer.zero?) unless Sync[self].nil?
      @state.step(@sequence.length)
      @sequence.at(@state.pointer) { |messages| perform(messages) }
    end

    private

    def perform(messages)
      unless messages.nil? || messages.empty?
        messages = @output_process.process(messages)
        @emitter.emit(messages)
      end
      @events.tick.call(messages, @state) unless @events.tick.nil? 
      reset if @state.reset?(&@events.reset_when)
      Sync[self].activate_queued unless Sync[self].nil?
      messages
    end

    def initialize_clock(tempo_or_input, resolution, options = {})
      @clock = Topaz::Tempo.new(tempo_or_input, :midi => options[:midi_outputs]) 
      @clock.interval = @clock.interval * (resolution / @clock.interval)
      @clock.on_tick { tick }
    end

    def get_clock_options(midi_outputs, flag_or_outputs)
      outputs = case flag_or_outputs
                when TrueClass then midi_outputs
                when Array, UniMIDI::Output then flag_or_outputs
                end
      outputs = [outputs].flatten
      {
        :midi_outputs => outputs
      }
    end

  end

end
