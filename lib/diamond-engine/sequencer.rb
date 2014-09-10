module DiamondEngine

  class Sequencer

    include SequencerAPI::Events
    include SequencerAPI::State

    attr_accessor :sequence, :perform
    attr_reader :events, :state, :name

    def initialize(options = {}, &block)   
      @events = Events.new
      @state = SequencerState.new
      @name = options[:name]
      @sequence = options[:sequence]
      @perform = block
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
      @clock.stop
      @state.stop
      @events.stop.call(@state) unless @events.stop.nil?
      yield if block_given?
      true            
    end

    def step
      @state.step(@sequence.length)
      true
    end

    private

    def perform
      @sequence.at(@state.pointer) do |data|
        @events.tick.call(data, @state) unless @events.tick.nil?
        @state.reset if @state.reset?(&@components[:events].reset_when)
        @perform.call(data) unless @perform.nil?
        true
      end
    end

  end

end

