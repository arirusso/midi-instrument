#!/usr/bin/env ruby
module DiamondEngine

  class SequencerClock
    
    extend Forwardable
    
    def_delegators :@clock, :join, :pause, :start, :stop, :tempo, :tempo=, :unpause
    
    def initialize(tempo_or_input, resolution, destinations = [], &block)
      @clock = Topaz::Tempo.new(tempo_or_input, :midi => destinations)
      dif = resolution / @clock.interval  
      @clock.interval = @clock.interval * dif
      @clock.on_tick(&block)
    end
    
    def output_midi_clock_to(destination)
      @clock.remove_destination(destination)
      @clock.add_destination(destination)
    end
           
  end
  
end
