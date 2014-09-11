module DiamondEngine

  class Events

    attr_accessor :perform,
                  :start, 
                  :step
          
    def initialize(&block)
      @rest_when = nil
      @reset_when = nil
      @start = nil
      @stop = nil
      @stop_when = nil
      @tick = nil
      @perform = block
    end

    # When true, the sequence will go back to step 0
    def reset_when(&block)
      @reset_when = block  
    end

    def stop(&block)
      @stop = block
    end

    def do_stop(state)
      @stop.call(state) unless @stop.nil?
    end

    # When true, no messages will be outputted during that step
    def rest_when(&block)
      @rest_when = block
    end

    def reset?(data, state)
      !@reset_when.nil? && @reset_when.call(data, state)
    end

    def stop_when(&block)
      @stop_when = block
    end

    def stop?(data, state)
      !@stop_when.nil? && @stop_when.call(data, state)
    end

    def perform(data)
      @perform.call(data) unless @perform.nil?
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
