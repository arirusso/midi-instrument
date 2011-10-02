#!/usr/bin/env ruby
module DiamondEngine
  
  class MIDIEmitter
    
    attr_reader :clock_destinations, :destinations
    
    # toggle mute on this emitter
    def toggle_mute
      muted? ? unmute : mute
    end
    
    # mute this emitter
    def mute
      @mute = true
    end
    
    # unmute this emitter
    def unmute
      @mute = false
    end
    
    # is this emitter muted?
    def muted?
      @mute
    end
    
    # stop and send note-offs to all destinations for all notes and channels
    def quiet!
      @destinations.each do |output|
        (0..127).each do |note| 
          (0..15).each do |channel|
            msg = MIDIMessage::NoteOff.new(channel, note, 0) 
            output.puts(msg.to_bytes)
          end
        end
      end
      true
    end
    
    # add an output where MIDI data will be sent
    def add_destinations(destinations)
      destinations = [destinations].flatten.compact
      @destinations += destinations
    end
    alias_method :add_destination, :add_destinations
    
    # remove a destination
    def remove_destinations(destinations)
      destinations = [destinations].flatten.compact
      @destinations.delete_if { |d| destinations.include?(d) }
    end
    alias_method :remove_destination, :remove_destinations
    
    def add_clock_destinations(destinations, clock)
      @clock_destinations += destinations
      @clock_destinations.uniq!
      refresh_clock(clock)
    end
    
    def remove_clock_destinations(destinations, clock)
      @clock_destinations.delete_if { |d| destinations.include?(d) }
      refresh_clock(clock)
    end
    
    # send MIDI messages to all destinations
    def emit(msgs)
      unless muted?
        data = as_data([msgs].flatten)
        @destinations.each { |o| o.puts(data) }
      end
    end
    
    # output MIDI clock from <em>clock</em> to this emitter's destinations
    def refresh_clock(clock)
      # the clock is actually responsible for emitting clock messages
      # so we just make sure it has a hold of the current destinations
      # for this emitter
      @clock_destinations.each { |dest| clock.refresh_midi_clock_destinations(dest) }
    end
        
    def initialize(devices = nil, options = {})
      @clock_destinations = []
      @destinations = []
      @mute = false
      @processors = []
      
      add_destinations(devices) unless devices.nil?   
    end
     
    private
    
    def as_data(msgs)
      msgs.map { |msg| msg.to_bytes }.flatten
    end
          
  end
  
end
