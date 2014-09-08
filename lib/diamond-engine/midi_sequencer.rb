module DiamondEngine

  class MIDISequencer
    
    include SequencerInternalCallbacks
    include SequencerUserCallbacks  
    include Syncable
    
    extend Forwardable
    
    attr_accessor :midi_clock_output, :sequence, :name
    attr_reader :output_process, :state
    
    def_delegator :@emitter, :destinations, :midi_destinations
    def_delegator :@emitter, :clock_destinations, :midi_clock_destinations
    def_delegator :state, :reset_pointer, :reset
    def_delegators :state, :running?
    def_delegators :@clock, :join, :tempo, :tempo=
    def_delegators :@emitter, :muted?, :toggle_mute, :mute, :mute=
    
    alias_method :focus, :join
    alias_method :midi_clock_output?, :midi_clock_output
    alias_method :running, :running?

    def initialize(tempo_or_input, options = {}, &block)
          
      devices = [(options[:midi] || [])].flatten
      output_devices = devices.select { |device| device.respond_to?(:puts) }  
      resolution = options[:resolution] || 128
      
      @midi_clock_output = options.fetch(:midi_clock_output, false)
      clock_output_devices = output_devices if @midi_clock_output  
     
      @name = options[:name]
      @sequence = options[:sequence]
      @output_process = ProcessChain.new
      @clock = SequencerClock.new(tempo_or_input, resolution, clock_output_devices) { tick }
      @emitter = MIDIEmitter.new(output_devices, options)
      @state = SequencerState.new
      
      initialize_internal_callbacks
      initialize_user_callbacks
      initialize_syncable(options[:sync_to], options[:sync])
      
      bind_events

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
      @internal_event[:before_start].each(&:call)
      opts = {}
      opts[:background] = true unless options[:focus] || options[:foreground]
      @internal_event[:after_start].each(&:call)
      @state.start
      @clock.start(opts) unless options[:suppress_clock]
      true
    end
    
    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop(options = {})
      @internal_event[:before_stop].each(&:call)
      @clock.stop rescue false
      @state.stop
      emit_pending_note_offs
      @internal_event[:after_stop].each(&:call)
      true            
    end

    # add a destination for midi data
    def add_midi_destinations(destinations)
      @emitter.add_destinations(destinations)
      @emitter.add_clock_destinations(destinations, @clock) if midi_clock_output?
      @internal_event[:midi_emitter_updated].each { |event| event.call(destinations) }
    end
    alias_method :add_midi_destination, :add_midi_destinations
    
    # remove a destination for midi data
    def remove_midi_destinations(destinations)
      @emitter.remove_destinations(destinations)
      @emitter.remove_clock_destinations(destinations, @clock) if midi_clock_output?
      @internal_event[:midi_emitter_updated].each { |event| event.call(destinations) }
    end
    alias_method :remove_midi_destination, :remove_midi_destinations
    
    protected
    
    # send all of the note off messages in the queue
    def emit_pending_note_offs
      messages = @sequence.pending_note_offs
      @emitter.emit(messages) unless messages.empty?
    end
    
    protected
    
    def process_output(messages)
      @output_process.process(messages)
    end
    
    def tick
      @internal_event[:before_tick].each { |event| event.call(@state.pointer) }
      @state.step(@sequence.length)
      @sequence.at(@state.pointer) do |messages|
        unless messages.nil? || messages.empty?
          messages = process_output(messages) 
          @emitter.emit(messages)
        end
        @internal_event[:after_tick].each { |event| event.call(messages) }
      end
    end
    
    private

    #
    # The point of this is to add and remove sync'd instruments'
    # midi clock outputs when they are queued to sync on a future beat
    #
    # the handle_updated callback is called on the beat when the sync actually
    # occurs
    #
    # it's not straightforward because midi clock output is handled by
    # the clock itself and other midi output is handled by the MIDIEmitter
    # 
    # Doing it as a callback this way maintains the decoupling of the
    # MIDIEmitter and Syncable.  The Syncable just calls the @internal_event[:sync_updated]
    # callbacks and this particular callback tells the emitter to add the outputs
    # belonging to the syncables to the clock
    #
    # if the parent syncable has midi_clock_output disabled, it will not continue
    # to send clock to its children, even if they had previously been
    # sending clock before the sync occurred.
    #
    def bind_events
      @internal_event[:sync_added] << Proc.new do |syncables| 
        if midi_clock_output?
          @emitter.add_clock_destinations(midi_clock_outputs, @clock)
        end
      end
      @internal_event[:sync_removed] << Proc.new do |syncables| 
        if midi_clock_output?
          @emitter.remove_clock_destinations(midi_clock_outputs, @clock)
        end
      end
    end

    def midi_clock_outputs
      syncables.select(&:midi_clock_output?).map(&:midi_clock_destinations)
    end
        
  end
  
end
