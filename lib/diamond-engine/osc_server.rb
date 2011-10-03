#!/usr/bin/env ruby
module DiamondEngine
  
  class OSCServer
    
    def initialize(instrument, port, map, options = {})
      @server = OSC::EMServer.new( 8000 )
      load_osc_map(instrument, map)
    end
    
    def start(options = {})
      background = options[:background] === true
      if background
        Thread.new do
          @server.run 
        end
      else
        @server.run 
      end
    end
    
    def stop(options = {})
      @server.stop
    end
    
    private
    
    def compute_value(value, range)
      length = range.last - range.first
      range.first + (value * length).to_i
    end
    
    def add_mapping(instrument, mapping)
      @server.add_method(mapping[:pattern]) do | message |
        raw_value = message.to_a.first
        computed_value = compute_value(raw_value, mapping[:range])
        instrument.send(mapping[:property], computed_value) if instrument.respond_to?(mapping[:property])
        #p "set #{mapping[:property]} to #{computed_value}"
      end
    end
    
    def load_osc_map(instrument, map)
      @map = map
      @map.each { |mapping| add_mapping(instrument, mapping) }
    end
          
  end
  
end
