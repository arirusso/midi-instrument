module MIDISequencer 
  
  class Listener
    
    extend Forwardable
    
    attr_reader :sources
    
    def_delegators :@listener, :stop
    def_delegator :@listener, :remove_listener, :delete_event
    
    def initialize(instrument, sources, options = {})
      @instrument = instrument
      @sources = [sources].flatten
      @listener = MIDIEye::Listener.new(sources)
      load_midi_map(options[:map]) unless options[:map].nil?
      start
    end
    
    def receive(name, match = {}, &block)
      match[:listener_name] = name    
      @listener.listen_for(match) { |event| yield(instrument, event) }
      @listener.start(:background => true)
      true
    end
    
    def add(source)
      sources = [source].flatten.select { |source| !@sources.include?(source) }
      @listener.add_input(sources)
      @sources += sources
      @sources
    end
    
    def remove(source)
      sources = [source].flatten
      @sources.delete_if { |source| sources.include?(source) }
      @listener.remove_input(sources)
      @sources
    end
    
    protected
    
    def start
      @listener.start(:background => true)
    end
    
    def load_midi_map(map)
      map.each do |item|
        name = "#{item[:property]}_#{map.index(item)}"
        receive(name, item[:match]) do |instrument, event|
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
