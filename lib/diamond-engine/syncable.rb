module DiamondEngine

  module Syncable

    # Is this clock master of the given syncable?
    def has_sync_slave?(syncable)
      !DiamondEngine::Sync[self].nil? && DiamondEngine::Sync[self].slave?(syncable)
    end
    alias_method :syncs?, :has_sync_slave?

    # Is this clock slave to the given syncable?
    def has_sync_master?(syncable)
      !DiamondEngine::Sync[syncable].nil? && DiamondEngine::Sync[syncable].slave?(self)
    end
    alias_method :synced_to?, :has_sync_master?

    # Is this clock synced with the given syncable either as master or slave?
    def sync?(syncable)
      has_sync_slave?(syncable) || has_sync_master?(syncable)
    end

    # Send sync to syncable
    def sync_to(syncable, options = {})
      if DiamondEngine::Sync[self].nil?
        DiamondEngine::Sync[self] = DiamondEngine::Sync.new(self, options.merge(:slave => syncable))
      else
        DiamondEngine::Sync[self]
      end
    end
    alias_method :sync, :sync_to

    # Stop sending sync to/from the given syncable
    def unsync(syncable)
      !Sync[self].nil? && Sync[self].remove(syncable) | !Sync[syncable].nil? && Sync[syncable].remove(self)
    end

    # Receive sync from syncable
    def sync_to(syncable, options = {})
      if DiamondEngine::Sync[syncable].nil?
        DiamondEngine::Sync[syncable] = DiamondEngine::Sync.new(syncable, options.merge(:slave => self))
      else
        DiamondEngine::Sync[syncable]
      end
    end

    # Stop receiving sync from syncable
    def unsync_from(syncable)
      !DiamondEngine::Sync[syncable].nil? && DiamondEngine::Sync[syncable].remove(self)
    end

    private

    def sync_enqueued
      Sync.activate_queued(self) 
    end

    def sync_immediate
      Sync.activate_queued(self, :immediate => true) 
    end

  end
end
