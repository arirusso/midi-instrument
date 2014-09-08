module DiamondEngine
  
  class MIDIListener
    
    extend Forwardable
    
    attr_reader :sources
    
    def_delegators :@listener, :stop
    def_delegator :@listener, :remove_listener, :delete_event
    
    def initialize(instrument, sources, options = {})
      @sources = sources
      @listener = MIDIEye::Listener.new(sources)
      load_midi_map(instrument, options[:map]) unless options[:map].nil?
      start
    end
    
    def receive_midi(instrument, name, match = {}, &block)
      match[:listener_name] = name    
      @listener.listen_for(match) { |event| yield(instrument, event) }
      @listener.start(:background => true)
      true
    end
    
    def add_source(source)
      sources = [source].flatten
      @listener.add_input(sources)
      @sources += sources
      @sources.uniq!
    end
    alias_method :add_sources, :add_source
    
    def remove_source(source)
      sources = [source].flatten
      @sources.delete_if { |source| sources.include?(source) }
      @listener.remove_input(sources)
    end
    alias_method :remove_sources, :remove_source
    
    protected
    
    def start
      @listener.start(:background => true)
    end
    
    def load_midi_map(instrument, map)
      map.each do |item|
        name = "#{item[:property]}_#{map.index(item)}"
        receive_midi(instrument, name, item[:match]) do |instrument, event|
          handle_event(instrument, event, item)
        end
      end
    end

    private

    def handle_event(instrument, event, item)
      Thread.abort_on_exception = true
      message = event[:message]
      raw_value = message.send(item[:using])
      value = if item[:new_range].nil?
        raw_value 
      else
        scale_value(raw_value, item)
      end
      instrument.send(item[:property], value)
    end

    def scale_event_value(raw_value, map)
      scaled = Scale.transform(raw_value).from(map[:original_range]).to(map[:new_range])
      scaled = scaled.to_i unless map[:type] == "float"
      scaled
    end
              
  end
  
end
