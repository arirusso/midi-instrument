module DiamondEngine

  class Sequencer

    attr_reader :events, :state

    def initialize(options = {}, &block)   
      @events = Events.new(&block)
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
      @events.start.call(@state) unless @events.start.nil?
      @state.start
      yield if block_given?
      true
    end

    # stops the clock and sends any remaining MIDI note-off messages that are in the queue
    def stop(options = {}, &block)
      @state.stop
      @events.do_stop(@state)
      yield if block_given?
      true            
    end

    def step(sequence)
      @state.step(sequence.length)
      @events.step.call(data, @state) unless @events.step.nil?
      true
    end

    def perform(sequence)
      data = sequence.at(@state.pointer)
      unless data.nil?
        stop if @events.stop?(data, @state)
        @state.reset if @events.reset?(data, @state)
        @events.perform(data)
        true
      end
    end

  end

end

