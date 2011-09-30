#!/usr/bin/env ruby
module DiamondEngine

  class MIDISequencer
    
    include SequencerCallbacks  
    include Syncable
    
    extend Forwardable
    
    attr_accessor :sequence
    attr_reader :output_process, :state
    def_delegator :@emitter, :destinations, :midi_destinations
    def_delegator :state, :reset_pointer, :reset
    def_delegators :state, :running?
    def_delegators :@clock, :join, :tempo, :tempo=
    def_delegators :@emitter, :muted?, :toggle_mute, :unmute
    alias_method :focus, :join

    def initialize(tempo_or_input, options = {}, &block)
      
      @events = { 
        :before_start => [],
        :before_stop => [],
        :before_tick => [],
        :after_start => [],
        :after_stop => [],
        :after_tick => [],
        :midi_emitter_updated => [],
      }   
      @mute = false      
      
      midi_clock_output = options[:midi_clock_output] || false  
      devices = [(options[:midi] || [])].flatten
      output_devices = devices.find_all { |d| d.respond_to?(:puts) }.compact  
      clock_output_devices = midi_clock_output ? output_devices : nil  
      resolution = options[:resolution] || 128

      @sequence = options[:sequence]
      @output_process = ProcessChain.new
      @clock = SequencerClock.new(tempo_or_input, resolution, clock_output_devices) { tick }
      @emitter = MIDIEmitter.new(output_devices, options)
      @state = SequencerState.new
      
      initialize_syncable(options[:sync_to], options[:sync])
      initialize_callbacks
      
      bind_events

      edit(&block) unless block.nil?
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
      self.instance_eval(&block)
    end
    
    # start the clock
    def start(options = {})     
      trap "SIGINT", proc { 
        quiet!        
        #exit
      }
      @events[:before_start].each(&:call)
      opts = {}
      opts[:background] = true unless options[:focus] || options[:foreground]
      @events[:after_start].each(&:call)
      @state.start
      @clock.start(opts)
      true
    end
    
    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop
      @events[:before_stop].each(&:call)
      @clock.stop rescue false
      @state.stop
      emit_pending_note_offs
      @events[:after_stop].each(&:call)
      true            
    end
    
    # add a destination for midi data
    def add_midi_destinations(destinations)
      @emitter.add_destinations(destinations)
      @events[:midi_emitter_updated].each(&:call)
    end
    alias_method :add_midi_destination, :add_midi_destinations
    
    # remove a destination for midi data
    def remove_midi_destinations(destinations)
      @emitter.remove_destinations(destinations)
      @events[:midi_emitter_updated].each(&:call)
    end
    alias_method :remove_midi_destination, :remove_midi_destinations
    
    protected
    
    # send all of the note off messages in the queue
    def emit_pending_note_offs
      msgs = @sequence.pending_note_offs
      @emitter.emit(msgs) unless msgs.empty?
    end
    
    protected
    
    def process_output(msgs)
      @output_process.process(msgs)
    end
    
    def tick
      @events[:before_tick].each { |event| event.call(@state.pointer) }
      @state.step(@sequence.length)
      @sequence.at(@state.pointer) do |msgs|
        unless msgs.nil? || msgs.empty?
          msgs = process_output(msgs) 
          @emitter.emit(msgs)
        end
        @events[:after_tick].each { |event| event.call(msgs) }
      end
    end
    
    private

    def bind_events
      handle_updated = Proc.new { @emitter.enable_clock_output(@clock) }
      @events[:midi_emitter_updated] << handle_updated
      @events[:sync_updated] << handle_updated
    end
        
  end
  
end
