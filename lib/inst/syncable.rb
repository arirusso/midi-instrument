#!/usr/bin/env ruby
module Inst
  
  module Syncable
    
    # sync another <em>syncable</em> to self
    # pass :now => true to queue the sync to happen immediately
    # otherwise the sync will happen at the beginning of self's next sequence
    def sync(syncable, options = {})
      unless sync?(syncable)
        @sync.add(syncable, options)       
        @events[:sync_updated].each(&:call)
      end
    end
    
    # is this instrument master of <em>syncable</em>?
    def syncs?(syncable)
      @sync.include?(syncable)
    end
    
    # is this instrument slave to <em>syncable</em>?
    def synced_to?(syncable)
      syncable.syncs?(self)
    end
    
    # is this instrument synced with <em>syncable<em> either as master or slave?
    def sync?(syncable)
      syncs?(syncable) || synced_to?(syncable)
    end
        
    # receive sync from <em>syncable</em>
    def sync_to(syncable, options = {})
      syncable.sync(self, options)
    end
    
    # stop sending sync to <em>syncable</em>
    # can unlink any configuration of sync between two syncables
    def unsync(syncable)
      if sync?(syncable)
        @sync.remove(syncable)
        @events[:sync_updated].each(&:call)
        syncable.unsync(self)
      end
    end
    
    # stop receiving sync from <em>syncable</em>
    def unsync_from(syncable)
      syncable.unsync(self)
    end
    
    # disable internal clock
    def pause_clock
      @clock.pause
    end
    
    # enable internal clock
    def unpause_clock
      @clock.unpause
    end
    
    private
    
    def bind_sync_events
      @events[:before_tick] << Proc.new do |pointer|
        now = pointer.zero? 
        @sync.activate_queued(now) 
      end
      @events[:after_tick] << Proc.new do 
        @sync.tick
        @sync.activate_queued
      end
      @events[:after_stop] << Proc.new { @sync.stop }
    end
    
    def initialize_syncable(sync_to, sync)
      @sync = SyncScheme.new
      unless sync_to.nil?
        sync_to = [sync_to].flatten.compact      
        sync_to.each { |syncable| sync_to(syncable) }
      end
      unless sync.nil?
        sync = [sync].flatten.compact
        sync.each { |syncable| sync(syncable) }
      end
      bind_sync_events
    end
          
  end
  
end
