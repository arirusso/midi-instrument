#!/usr/bin/env ruby
module DiamondEngine

  module SequencerUserCallbacks
    
    # bind an event that occurs every time the clock ticks
    def on_tick(&block)
      @user_event[:tick] = block
    end
    
    # bind an event that occurs on start
    def on_start(&block)
      @user_event[:start] = block
    end
    
    # bind an event that occurs on stop
    def on_stop(&block)
      @user_event[:stop] = block
    end 

    # bind an event where if it evaluates to true, no messages will be outputted during that
    # step. (however, the tick event will still be fired)
    # MIDISequencer#sequence is passed to the block
    def rest_when(&block)
      @user_event[:rest_when] = block
    end
    
    # should the instrument rest on the current step?
    def rest?
      @user_event[:rest_when].nil? ? false : @user_event[:rest_when].call(@state) 
    end
    
    # bind an event where the instrument plays a rest on every <em>num<em> beat
    # passing in nil will cancel any rest events 
    def rest_every(num)
      num.nil? ? @user_event[:rest_when] = nil : rest_when { |s| s.pointer % num == 0 }
      true
    end

    # bind an event where the instrument resets on every <em>num<em> beat
    # passing in nil will cancel any reset events 
    def reset_every(num)
      num.nil? ? @user_event[:reset_when] = nil : reset_when { |s| s.pointer % num == 0 }
      true
    end
        
    # remove all note-on messages
    def rest_event_filter(msgs)
      msgs.delete_if { |m| m.class == MIDIMessage::NoteOn }
    end

    # if it evaluates to true, the sequence will go back to step 0
    # MIDISequencer#sequence is passed to the block  
    def reset_when(&block)
      @user_event[:reset_when] = block
    end
    
    # should the instrument reset on the current step?
    def reset?
      @user_event[:reset_when].nil? ? false : @user_event[:reset_when].call(@state) 
    end
    
    private
    
    def initialize_user_callbacks
      @user_event ||= { }
      @internal_event[:after_tick] << Proc.new do |msgs|
        @user_event[:tick].call(msgs, @state) unless @user_event[:tick].nil? 
        reset if reset?
      end
      @internal_event[:before_start] << Proc.new { @user_event[:start].call(@state) unless @user_event[:start].nil? }
      @internal_event[:after_stop] << Proc.new { @user_event[:stop].call(@state) unless @user_event[:stop].nil? }
    end
        
  end
  
end
