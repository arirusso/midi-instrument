#!/usr/bin/env ruby
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
      @listener.listen_for(match) do |event|
        block.call(instrument, event)
      end
      @listener.start(:background => true)
      true
    end
    
    def add_source(source)
      sources = [source].flatten
      @listener.sources += sources
      @listener.sources.uniq!
      @sources += sources
      @sources.uniq!
    end
    alias_method :add_sources, :add_source
    
    def remove_source(source)
      sources = [source].flatten
      @sources.delete_if { |s| sources.include?(s) }
      @listener.sources.delete_if { |s| sources.include?(s) }
    end
    alias_method :remove_sources, :remove_source
    
    protected
    
    def start
      @listener.start(:background => true)
    end
    
    def load_midi_map(instrument, map)
      map.each do |item|
        name = "#{item[:property]}_#{map.index(item)}".to_sym
        receive_midi(instrument, name, item[:match]) do |instrument, event|
          Thread.abort_on_exception = true
          msg = event[:message]
          raw_value = msg.send(item[:using])
          computed_value = item[:new_range].nil? ? raw_value : compute_value(raw_value, item[:original_range], item[:new_range], :type => item[:type])
          instrument.send(item[:property], computed_value)
        end
      end
    end
    
    def compute_value(raw_value, old_range, new_range, options = {})
      new_range_length = new_range.last - new_range.first
      old_range_length = old_range.last - old_range.first
      factor = new_range_length.to_f / old_range_length.to_f
      computed_value = raw_value.to_f * factor.to_f
      computed_value = computed_value + new_range.first # offset
      float_requested = !options[:type].nil? && options[:type].to_s.downcase == "float"
      float_requested ? computed_value : computed_value.to_i
    end
          
  end
  
end
