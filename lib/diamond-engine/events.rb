module DiamondEngine

  class Events

    attr_accessor :reset_when, # when true, the sequence will go back to step 0
                  :rest_when,  # when true, no messages will be outputted during that step
                  :start, 
                  :stop, 
                  :perform
    alias_method :on_start, :start=
    alias_method :on_stop, :stop=
    alias_method :on_perform, :perform=
    
    def initialize
      @rest_when = nil
      @reset_when = nil
      @start = nil
      @stop = nil
      @perform = nil
    end
        
    # Bind an event when the instrument plays a rest on every given beat
    # Passing in nil will cancel any existing rest events 
    # @param [Fixnum] num The number of recurring beats to rest on
    # @return [Fixnum, nil]
    def rest_every(num)
      if num.nil?
        @rest_when = nil
      else
        rest_when { |step| step.pointer % num == 0 }
        num
      end
    end

    # Bind an event where the instrument resets on every <em>num<em> beat
    # passing in nil will cancel any reset events 
    def reset_every(num)
      if num.nil?
        @reset_when = nil
      else
        reset_when { |step| step.pointer % num == 0 }
        num
      end
    end
            
  end
  
end
