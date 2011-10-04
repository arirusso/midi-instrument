#!/usr/bin/env ruby
module DiamondEngine
  
  module ReceivesOSC
    
    def receive_osc(pattern, &block)
      @osc_server.add_method(self, pattern, &block)
    end
    
    private
    
    def initialize_osc_listener(port, map, options = {})
      @osc_server = OSCServer.new(self, port, map)
      @osc_server.start(:background => true) unless !options[:start_osc].nil? && options[:start_osc] == false 
      #@internal_event[:before_start] << Proc.new { @osc_server.start(:background => true) }
    end
          
  end
  
end
