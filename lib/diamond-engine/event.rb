module DiamondEngine

  class Event

    attr_accessor :perform,
                  :start, 
                  :step
          
    def initialize(&block)
      @start = nil
      @stop = nil
      @tick = nil
      @perform = block
    end

    def stop(&block)
      @stop = block
    end

    def do_stop(state)
      @stop.call(state) unless @stop.nil?
    end

    def perform(data)
      @perform.call(data) unless @perform.nil?
    end
                    
  end
  
end
