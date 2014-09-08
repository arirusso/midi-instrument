module DiamondEngine
  
  class MIDIEmitter
    
    attr_accessor :mute
    attr_reader :clock_destinations, :destinations
    
    def initialize(devices = nil, options = {})
      @clock_destinations = []
      @destinations = []
      @mute = false
      @processors = []
      
      add_destinations(devices) unless devices.nil?   
    end

    # Toggle mute on this emitter
    def toggle_mute
      @mute = !@mute
    end
    
    # Is this emitter muted?
    def muted?
      @mute
    end
    
    # Stop and send note-offs to all destinations for all notes and channels
    def quiet!
      @destinations.each do |output|
        (0..127).each do |note| 
          (0..15).each do |channel|
            message = MIDIMessage::NoteOff.new(channel, note, 0) 
            output.puts(message.to_bytes)
          end
        end
      end
      true
    end
    
    # Add an output where MIDI data will be sent
    def add_destinations(destinations)
      destinations = [destinations].flatten.compact
      @destinations += destinations
    end
    alias_method :add_destination, :add_destinations
    
    # Remove a destination
    def remove_destinations(destinations)
      destinations = [destinations].flatten.compact
      @destinations.delete_if { |destination| destinations.include?(destination) }
    end
    alias_method :remove_destination, :remove_destinations
    
    def add_clock_destinations(destinations, clock)
      @clock_destinations += destinations
      @clock_destinations.uniq!
      clock.add_destination(destinations)
    end
    
    def remove_clock_destinations(destinations, clock)
      @clock_destinations.delete_if { |destination| destinations.include?(destination) }
      clock.remove_destination(destinations)
    end
    
    # Send MIDI messages to all destinations
    def emit(messages)
      unless muted?
        data = as_data([messages].flatten)
        @destinations.each { |destination| destination.puts(data) }
      end
    end
             
    private
    
    def as_data(messages)
      messages.map(&:to_bytes).flatten
    end
          
  end
  
end
