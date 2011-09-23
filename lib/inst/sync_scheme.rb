#!/usr/bin/env ruby
module Inst
  
  class SyncScheme
    
    attr_reader :queue, :syncables
    
    def initialize
      @queue ||= {}
      @syncables ||= []
    end
    
    # sync another <em>syncable</em> to self
    # pass :now => true to queue the sync to happen immediately
    # otherwise the sync will happen at the beginning of self's next sequence
    def add(syncable, options = {})
      @queue[syncable] = options[:now] || false
      true               
    end
    
    # is <em>syncable</em> synced to this instrument?
    def include?(syncable)
      @syncables.include?(syncable) || @queue.include?(syncable)
    end
    
    # stop sending sync to <em>syncable</em>
    def remove(syncable)
      @syncables.delete(syncable)
      @queue.delete(syncable)
      syncable.unpause_clock
      true
    end
    
    def tick
      @syncables.each(&:sync_tick)
    end
    
    # you don't truly hear sync until syncables are moved from the queue to the syncables set 
    def activate(force_sync_now)
      updated = false
      @queue.each do |syncable, sync_now|
        if sync_now || force_sync_now 
          @syncables << syncable
          syncable.pause_clock
          @queue.delete(syncable)
          updated = true
        end
      end
    end
          
  end
  
end
