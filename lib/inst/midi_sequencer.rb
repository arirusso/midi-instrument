#!/usr/bin/env ruby
module Inst

  class MIDISequencer
    
    include Inst::SequencerCallbacks  
    include Inst::Syncable
    
    extend Forwardable
    
    attr_accessor :sequence
    attr_reader :output_processors, :state
    def_delegator :@midi_emitter, :destinations, :midi_destinations
    def_delegator :state, :reset_pointer, :reset
    def_delegators :clock, :join, :tempo, :tempo=
    def_delegators :@midi_emitter, :muted?, :toggle_mute, :unmute
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
      @output_processors = {}
      
      midi_clock_output = options[:midi_clock_output] || false  
      devices = [(options[:midi] || [])].flatten
      output_devices = devices.find_all { |d| d.respond_to?(:puts) }.compact  
      clock_output_devices = midi_clock_output ? output_devices : nil  
      resolution = options[:resolution] || 128

      @sequence = options[:sequence]
      @midi_emitter = MIDIEmitter.new(output_devices, options)
      @state = SequencerState.new
      
      initialize_syncable(options[:sync_to], options[:sync])
      initialize_callbacks
      @clock = SequencerClock.new(tempo_or_input, resolution, clock_output_devices) { tick }

    end
    
    def quiet!
      stop
      @midi_emitter.quiet!
    end
       
    # mute the sequencer 
    def mute
      emit_pending_note_offs
      @midi_emitter.mute
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
      @midi_emitter.add_destinations(destinations)
      @events[:midi_emitter_updated].each(&:call)
    end
    alias_method :add_midi_destination, :add_midi_destinations
    
    # remove a destination for midi data
    def remove_midi_destinations(destinations)
      @midi_emitter.remove_destinations(destinations)
      @events[:midi_emitter_updated].each(&:call)
    end
    alias_method :remove_midi_destination, :remove_midi_destinations
    
    protected
    
    # send all of the note off messages in the queue
    def emit_pending_note_offs
      data = @sequence.pending_note_offs.map { |msg| msg.to_bytes }.flatten.compact
      @midi_emitter.emit(data) unless data.empty?
    end
    
    protected
    
    def tick
      @events[:before_tick].each { |event| event.call(pointer) }
      step
      @sequence.step(@state.pointer) do |msgs| 
        do_output(msgs) unless muted?
        @events[:after_tick].each { |event| event.call(msgs) }
      end
    end
    
    private

    def bind_events
      handle_updated = Proc.new do
        @midi_emitter.enable_clock_output(@clock)
      end
      @events[:midi_emitter_updated] << handle_updated
      @events[:sync_updated] << handle_updated
    end
    
    def step
      @state.pointer = (@state.pointer >= (@sequence.length - 1)) ? 0 : @state.pointer + 1
    end
    
    def process_messages(msgs)
      @output_processors.values.map { |processor| processor.process(msgs) }.flatten.compact
    end
    
    def as_data(msgs)
      msgs.map { |msg| msg.to_bytes }.flatten
    end
    
    def do_output(msgs)
      data = as_data(process_messages(msgs))
      @midi_emitter.emit(data) unless data.empty?
    end
        
  end
  
end
