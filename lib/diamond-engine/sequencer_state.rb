#!/usr/bin/env ruby
module DiamondEngine

  class SequencerState
    
    attr_accessor :pointer

    def initialize
      @pointer = 0
      @running = false
    end
    
    def step(length)
      @pointer = (@pointer >= (length - 1)) ? 0 : @pointer + 1
    end
    
    # return to the beginning of the sequence
    def reset_pointer
      @pointer = 0
    end
    
    def running?
      @running
    end
    
    def start
      @running = true
    end
    
    def stop
      @running = false
    end
        
  end
  
end
