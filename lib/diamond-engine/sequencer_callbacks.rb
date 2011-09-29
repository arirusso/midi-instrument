#!/usr/bin/env ruby
module DiamondEngine

  module SequencerCallbacks
    
    # bind an event that occurs every time the clock ticks
    def on_tick(&block)
      @user_events[:tick] = block
    end
    
    # bind an event that occurs on start
    def on_start(&block)
      @user_events[:start] = block
    end
    
    # bind an event that occurs on stop
    def on_stop(&block)
      @user_events[:stop] = block
    end 

    # bind an event where if it evaluates to true, no messages will be outputted during that
    # step. (however, the tick event will still be fired)
    # MIDISequencer#sequence is passed to the block
    def rest_when(&block)
      @user_events[:rest_when] = block
    end
    
    # should the instrument rest on the current step?
    def rest?
      @user_events[:rest_when].nil? ? false : @user_events[:rest_when].call(@state) 
    end
    
    # bind an event where the instrument plays a rest on every <em>num<em> beat
    # passing in nil will cancel any rest events 
    def rest_every(num)
      num.nil? ? @user_events[:rest_when] = nil : rest_when { |s| s.pointer % num == 0 }
      true
    end

    # bind an event where the instrument resets on every <em>num<em> beat
    # passing in nil will cancel any reset events 
    def reset_every(num)
      num.nil? ? @user_events[:reset_when] = nil : reset_when { |s| s.pointer % num == 0 }
      true
    end
        
    # remove all note-on messages
    def rest_event_filter(msgs)
      msgs.delete_if { |m| m.class == MIDIMessage::NoteOn }
    end

    # if it evaluates to true, the sequence will go back to step 0
    # MIDISequencer#sequence is passed to the block  
    def reset_when(&block)
      @user_events[:reset_when] = block
    end
    
    # should the instrument reset on the current step?
    def reset?
      @user_events[:reset_when].nil? ? false : @user_events[:reset_when].call(@state) 
    end
    
    private
    
    def initialize_callbacks
      @user_events ||= { }
      @events[:after_tick] << Proc.new do |msgs|
        @user_events[:tick].call(msgs, @state) unless @user_events[:tick].nil? 
        reset if reset?
      end
      @events[:before_start] << Proc.new { @user_events[:start].call(@state) unless @user_events[:start].nil? }
      @events[:after_stop] << Proc.new { @user_events[:stop].call(@state) unless @user_events[:stop].nil? }
    end
        
  end
  
end
