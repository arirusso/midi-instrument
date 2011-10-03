#!/usr/bin/env ruby
module DiamondEngine
  
  module ReceivesOSC
    
    private
    
    def initialize_osc_server(port, map, options = {})
      @osc_server = OSCServer.new(self, port, map)
      @internal_event[:before_start] << Proc.new { @osc_server.start(:background => true) }
      @internal_event[:before_stop] << Proc.new { @osc_server.stop }
    end
          
  end
  
end
