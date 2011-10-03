#!/usr/bin/env ruby
module DiamondEngine
  
  module Syncable
    
    # sync another <em>syncable</em> to self
    # pass :now => true to queue the sync to happen immediately
    # otherwise the sync will happen at the beginning of self's next sequence
    def sync(syncable, options = {})
      unless sync?(syncable)
        @sync.add(syncable, options)       
        return true
      end
      false
    end
    
    # is this instrument master of <em>syncable</em>?
    def has_sync_child?(syncable)
      @sync.include?(syncable)
    end
    alias_method :syncs?, :has_sync_child?
    
    # is this instrument slave to <em>syncable</em>?
    def has_sync_parent?(syncable)
      syncable.syncs?(self)
    end
    alias_method :synced_to?, :has_sync_parent?
    
    # is this instrument synced with <em>syncable<em> either as master or slave?
    def sync?(syncable)
      has_sync_child?(syncable) || has_sync_parent?(syncable)
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
        remove_sync_children(syncable)
        syncable.unsync(self)
        return true
      end
      false
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
      @internal_event[:sync_added] = []
      @internal_event[:sync_removed] = []
      @internal_event[:before_tick] << Proc.new do |pointer|
        now = pointer.zero? 
        new_syncables = @sync.activate_queued(now)
        new_syncables.each { |s| s.start(:suppress_clock => true) unless s.running? }
        @internal_event[:sync_added].each { |e| e.call(new_syncables) } unless new_syncables.empty?
      end
      @internal_event[:after_tick] << Proc.new do |msgs|
        new_syncables = @sync.activate_queued
        @internal_event[:sync_added].each { |e| e.call(new_syncables) } unless new_syncables.empty?
        @sync.tick
      end
      @internal_event[:after_start] << Proc.new { @sync.start }
      @internal_event[:after_stop] << Proc.new { @sync.stop }
    end

    def remove_sync_children(syncables)
      @internal_event[:sync_removed].each { |e| e.call(syncables) }
    end
        
    def initialize_syncable(sync_to, sync)
      @sync = Sync.new
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
