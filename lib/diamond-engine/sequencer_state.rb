#!/usr/bin/env ruby
module DiamondEngine

  class SequencerState
    
    attr_accessor :pointer

    def initialize
      @pointer = 0
    end
    
    def step(length)
      @pointer = (@pointer >= (length - 1)) ? 0 : @pointer + 1
    end
    
    # return to the beginning of the sequence
    def reset_pointer
      @pointer = 0
    end
        
  end
  
end
