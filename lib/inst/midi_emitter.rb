#!/usr/bin/env ruby
module Inst
  
  class MIDIEmitter
    
    attr_reader :destinations
    
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
    
    # send MIDI data
    def emit(data)
      @destinations.each { |o| o.puts(data) } if emit?
    end
    
    # output MIDI clock from <em>clock</em> to this emitter's destinations
    def enable_clock_output(clock)
      # the clock is actually responsible for emitting clock messages
      # so we just make sure it has a hold of the current destinations
      # for this emitter
      @destinations.each { |dest| clock.output_midi_clock_to(dest) }
    end
        
    def initialize(devices = nil, options = {})
      @destinations = []
      @mute = false
      add_destinations(devices) unless devices.nil?   
    end
    
    protected
    
    # does this emitter have destinations?
    def emit?
      !@destinations.nil? && !@destinations.empty?
    end
          
  end
  
end
