#!/usr/bin/env ruby
module DiamondEngine

  class SequencerClock
    
    extend Forwardable
    
    def_delegators :@clock, :join, :pause, :start, :stop, :tempo, :tempo=, :unpause
    def_delegator :@clock, :add_destination, :add_midi_destinations
    def_delegator :@clock, :remove_destination, :remove_midi_destinations
    
    def initialize(tempo_or_input, resolution, destinations = [], &block)
      @clock = Topaz::Tempo.new(tempo_or_input, :midi => destinations)
      dif = resolution / @clock.interval  
      @clock.interval = @clock.interval * dif
      @clock.on_tick(&block)
    end
    
    def midi_destinations
      @clock.destinations.map(&:output)
    end
           
  end
  
end
