module DiamondEngine

  class Sequencer

    attr_reader :event, :trigger, :state

    def initialize(options = {})
      @event = Event.new
      @trigger = EventTrigger.new
      @state = SequencerState.new
    end

    # toggle start/stop
    def toggle_start
      running? ? stop : start
    end

    def running=(val)
      val ? start : stop
    end

    # start the clock
    def start(options = {}, &block)     
      trap "SIGINT", proc { 
        quiet!        
        exit
      }
      @state.start
      @event.do_start(@state)
      yield if block_given?
      true
    end

    # Stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop(options = {}, &block)
      @state.stop
      @event.do_stop(@state)
      yield if block_given?
      true            
    end

    def sync?
      @trigger.sync?(@state)
    end

    def step(sequence)
      @state.step(sequence.length)
      @event.do_step(@state)
      true
    end

    def perform(sequence)
      data = sequence.at(@state.pointer)
      unless data.nil?
        if @trigger.stop?(data, @state)
          stop
          false
        else
          if @trigger.reset?(data, @state)
            @state.reset 
          end
          @event.do_perform(data, @state)
          true
        end
      end
    end

  end

end

