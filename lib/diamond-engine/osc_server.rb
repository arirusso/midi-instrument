#!/usr/bin/env ruby
module DiamondEngine
  
  class OSCServer
    
    extend Forwardable
    
    def_delegators :@server, :add_method
    
    def initialize(instrument, port, map, options = {})
      @server = OSC::EMServer.new( 8000 )
      load_osc_map(instrument, map)
    end
    
    def start(options = {})
      background = options[:background] === true
      if background
        @thread = Thread.new do
          @server.run 
        end
      else
        @server.run 
      end
    end
    
    def stop(options = {})
      @thread.kill
    end
    
    private
    
    def compute_value(value, range, options = {})
      length = range.last - range.first
      computed_value = range.first + (value * length.to_f)
      !options[:type].nil? && options[:type].to_s == "float" ? computed_value : computed_value.to_i
    end
    
    def add_mapping(instrument, mapping)
      @server.add_method(mapping[:pattern]) do | message |
        raw_value = message.to_a.first
        computed_value = compute_value(raw_value, mapping[:range], :type => mapping[:type])
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
