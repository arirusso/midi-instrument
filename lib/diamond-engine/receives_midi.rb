#!/usr/bin/env ruby
module DiamondEngine
  
  module ReceivesMIDI
    
    def receive_midi(name, match = {}, &block)
      @midi_listener.receive_midi(self, name, match, &block)
    end
    
    def add_midi_source(source)
      @midi_listener.add_source(source)
    end
    alias_method :add_midi_sources, :add_midi_source
    
    def remove_midi_source(source)
      @midi_listener.remove_source(source)
    end
    alias_method :remove_midi_sources, :remove_midi_source
    
    def midi_sources
      @midi_listener.sources
    end
    
    private
    
    def initialize_midi_receiver(inputs, options = {})
      map = options[:map]
      @midi_listener = MIDIListener.new(self, inputs, :map => map)
    end
          
  end
  
end
