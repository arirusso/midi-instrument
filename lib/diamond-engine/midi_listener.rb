#!/usr/bin/env ruby
module DiamondEngine
  
  class MIDIListener
    
    attr_reader :sources
    
    def initialize(instrument, sources, options = {})
      @listeners = {}
      @sources = sources
      load_midi_map(instrument, options[:map]) unless options[:map].nil?
      start
    end
    
    def receive_midi(instrument, name, match = {}, &block)
      listener = MIDIEye::Listener.new(@sources)
      listener.listen_for(:class => MIDIMessage::NoteOn) do |event|
        yield(instrument, event)
      end
      listener.start(:background => true)
      @listeners[name] = listener
      true
    end
    
    def remove_listener(name)
      @listeners.delete(name)
    end
    
    def add_source(source)
      sources = [source].flatten
      @sources += sources
      @listeners.values.each do |l|
        sources.each do |s|
          l.sources.push(s) unless l.sources.include?(s)
        end
      end     
    end
    alias_method :add_sources, :add_source
    
    def remove_source(source)
      sources = [source].flatten
      @sources.delete_if { |s| sources.include?(s) }
      @listeners.values.each do |l| 
        l.sources.delete_if { |s| sources.include?(s) }
      end
    end
    alias_method :remove_sources, :remove_source
    
    protected
    
    def start
      @listeners.values.each { |l| l.start(:background => true) }
    end
    
    def stop
      @listeners.values.each(&:stop)
    end
    
    def load_midi_map(instrument, map)
      receive_midi(:class => map[:class]) do |event|
        msg = event[:message]
        raw_value = msg.send(map[:index])
        computed_value = map[:input_range].nil? ? raw_value : compute_value(value, input_range, range, :type => map[:type])
        instrument.send(map[:property], computed_value)
      end
    end
    
    def compute_value(value, input_range, range, options = {})
      range_length = range.last - range.first
      input_range_length = input_range.last - input_range.first
      factor = range_length / input_range_length
      computed_value = value.to_f * factor.to_f
      !options[:type].nil? && options[:type].to_s.downcase == "float" ? computed_value : computed_value.to_i
    end
          
  end
  
end
