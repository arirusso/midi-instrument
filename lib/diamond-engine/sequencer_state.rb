#!/usr/bin/env ruby
module DiamondEngine

  class SequencerState
    
    attr_accessor :pointer

    def initialize
      @pointer = 0
    end
    
    # return to the beginning of the sequence
    def reset_pointer
      @pointer = 0
    end
        
  end
  
end
