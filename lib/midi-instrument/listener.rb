module MIDIInstrument

  # A light wrapper for MIDIEye::Listener
  class Listener
    
    extend Forwardable
        
    def_delegators :@listener, :add_input, :remove_input, :stop
    def_delegator :@listener, :remove_listener, :delete_event
    
    # @param [Array<UniMIDI::Input>, UniMIDI::Input] sources
    def initialize(sources)
      @listener = MIDIEye::Listener.new([sources].flatten)
    end

    # Manually add messages to the MIDI input buffer
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] args
    # @return [Array<MIDIMessage>]
    def add(*messages)
      [messages].flatten.map do |message|
        report = { 
          :message => message, 
          :timestamp => Time.now.to_f 
        }
        @listener.event.enqueue_all(report)
        report
      end
    end
    alias_method :<<, :add

    # Join the listener thread
    def join
      start if !@listener.running?
      @listener.join
    end

    # The active inputs
    # @return [Array<UniMIDI::Input>]
    def inputs
      @listener.sources
    end

    # Start the listener
    def start
      @listener.start(:background => true)
    end
    
    # Bind a message callback
    # @param [Hash] match
    # @param [Proc] callback
    # @return [Boolean]
    def receive(match = {}, &callback)
      @listener.listen_for(match, &callback)
      start if !@listener.running?
      true
    end
              
  end
  
end

