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
    def_delegators :clock, :join, :tempo, :tempo=
    def_delegators :@emitter, :muted?, :toggle_mute, :unmute
    alias_method :focus, :join

    def initialize(tempo_or_input, options = {})
      
      @events = { 
        :before_start => [],
        :before_tick => [],
        :after_stop => [],
        :after_tick => [],
        :midi_emitter_updated => [],
        :sync_updated => []
      }   
      @mute = false      
      @output_process = ProcessChain.new
      
      midi_clock_output = options[:midi_clock_output] || false  
      devices = [(options[:midi] || [])].flatten
      output_devices = devices.find_all { |d| d.respond_to?(:puts) }.compact  
      clock_output_devices = midi_clock_output ? output_devices : nil  
      resolution = options[:resolution] || 128

      @sequence = options[:sequence]
      @emitter = MIDIEmitter.new(output_devices, options)
      @state = SequencerState.new
      
      initialize_syncable(options[:sync_to], options[:sync])
      initialize_callbacks
      @clock = SequencerClock.new(tempo_or_input, resolution, clock_output_devices) { tick }

    end
    
    def quiet!
      stop
      @emitter.quiet!
    end
       
    # mute the sequencer 
    def mute
      emit_pending_note_offs
      @emitter.mute
    end
    
    # start the clock
    def start(options = {})      
      opts = {}
      opts[:background] = true unless options[:focus] || options[:foreground]
      @events[:before_start].each(&:call)
      trap "SIGINT", proc { 
        stop
        exit
      }
      @clock.start(opts)
      true
    end
    
    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop
      @clock.stop rescue false
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
      @events[:before_tick].each { |event| event.call(pointer) }
      step
      @sequence.step(@state.pointer) do |msgs|
        msgs = process_output(msgs) 
        @emitter.emit(msgs) unless muted? || msgs.nil? || msgs.empty?
        @events[:after_tick].each { |event| event.call(msgs) }
      end
    end
    
    private

    def bind_events
      handle_updated = Proc.new do
        @emitter.enable_clock_output(@clock)
      end
      @events[:midi_emitter_updated] << handle_updated
      @events[:sync_updated] << handle_updated
    end
    
    def step
      @state.pointer = (@state.pointer >= (@sequence.length - 1)) ? 0 : @state.pointer + 1
    end
        
  end
  
end
