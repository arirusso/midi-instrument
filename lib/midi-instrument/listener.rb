module MIDIInstrument

  class Listener
    
    extend Forwardable
        
    def_delegators :@listener, :add_input, :remove_input, :stop
    def_delegator :@listener, :remove_listener, :delete_event
    
    def initialize(sources)
      @listener = MIDIEye::Listener.new([sources].flatten)
    end

    # Add MIDI messages manually to the MIDI input buffer. 
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] args
    # @return [Array<MIDIMessage>]
    def add(*args)
      data = [args.dup].flatten
      messages = Message.to_messages(*data)
      messages.each do |message|
        report = { 
          :message => message, 
          :timestamp => Time.now.to_f 
        }
        @listener.event.enqueue_all(report)
      end
      messages
    end
    alias_method :<<, :add

    def join
      start if !@listener.running?
      @listener.join
    end

    def start
      @listener.start(:background => true)
    end
    
    def receive(match = {}, &callback)
      @listener.listen_for(match, &callback)
      start if !@listener.running?
      true
    end
              
  end
  
end

