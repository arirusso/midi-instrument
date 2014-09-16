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
        name = "#{item[:property]}_#{map.index(item)}"
        receive(item[:match]) do |event|
          handle_event(event, item)
        end
      end
    end

    private

    def handle_event(event, item)
      Thread.abort_on_exception = true
      message = event[:message]
      raw_value = message.send(item[:using])
      value = if item[:new_range].nil?
        raw_value 
      else
        scale_value(raw_value, item)
      end
      @instrument.send(item[:property], value)
    end

    def scale_event_value(raw_value, map)
      scaled = Scale.transform(raw_value).from(map[:original_range]).to(map[:new_range])
      scaled = scaled.to_i if map[:type] != "float"
      scaled
    end
              
  end
  
end

