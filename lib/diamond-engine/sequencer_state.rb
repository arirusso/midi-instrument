module DiamondEngine

  class SequencerState
    
    attr_accessor :pointer, :repeat

    def initialize
      @pointer = 0
      @repeat = 0
      @running = false
    end
    
    def step(length)
      if @pointer < length - 1
        @pointer += 1
      else
        reset_pointer
      end
      true
    end
    
    # Return to the beginning of the sequence
    def reset_pointer
      @pointer = 0
      @repeat += 1
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
