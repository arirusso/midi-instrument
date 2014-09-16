module MIDIInstrument

  class Listener
    
    extend Forwardable
        
    def_delegators :@listener, :add_input, :remove_input, :stop
    def_delegator :@listener, :remove_listener, :delete_event
    
    def initialize(instrument, sources, options = {})
      @instrument = instrument
      @listener = MIDIEye::Listener.new([sources].flatten)
      load_midi_map(options[:map]) unless options[:map].nil?
    end

    # Add MIDI messages manually to the MIDI input buffer. 
    # @param [Array<MIDIMessage>, MIDIMessage, *MIDIMessage] args
    def add(*args)
      data = [args.dup].flatten
      messages = Message.to_message(*data)
      messages.each do |message|
        report = { :message => message, :timestamp => Time.now.to_i }
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
    
    def receive(match = {}, &block)
      @listener.listen_for(match, &block)
      start if !@listener.running?
      true
    end
            
    private
    
    def load_midi_map(map)
      map.each do |item|
        receive(item[:match]) do |event|
          message = event[:message]
          item[:proc].call(message)
        end
      end
    end
              
  end
  
end

