#!/usr/bin/env ruby
module DiamondEngine

  module SequencerInternalCallbacks

    private
    
    def initialize_internal_callbacks
      @internal_event = { 
        :before_start => [],
        :before_stop => [],
        :before_tick => [],
        :after_start => [],
        :after_stop => [],
        :after_tick => [],
        :midi_emitter_updated => [],
      }
    end
        
  end
  
end
