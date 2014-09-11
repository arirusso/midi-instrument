module DiamondEngine

  class EventTrigger
          
    def initialize
      @rest = nil
      @reset = nil
      @stop = nil
    end

    # When true, the sequence will go back to step 0
    def reset(&block)
      @reset_when = block  
    end

    # When true, no messages will be outputted during that step
    def rest(&block)
      @rest_when = block
    end

    def reset?(data, state)
      !@reset_when.nil? && @reset_when.call(data, state)
    end

    def stop(&block)
      @stop_when = block
    end

    def stop?(data, state)
      !@stop_when.nil? && @stop_when.call(data, state)
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

