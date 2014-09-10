module DiamondEngine

  class Clock

    extend Forwardable

    def_delegators :@clock, :pause, :unpause

    def initialize(tempo_or_input, outputs, options = {}, &block)
      @pointer = options[:pointer]
      initialize_clock(tempo_or_input, options.fetch(:resolution, 128), :outputs => outputs, &block)
    end

    def stop
      @clock.stop
    end

    def start(options = {})
      clock_options = {}
      clock_options[:background] = true unless !!options[:focus] || !!options[:foreground]
      @clock.start(clock_options) unless !!options[:suppress_clock]
    end

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
      DiamondEngine::Sync[syncable].remove(self) unless DiamondEngine::Sync[syncable].nil?
    end

    private

    def tick(&block)
      Sync[self].activate_queued(:force_sync_now => @pointer.zero?) unless Sync[self].nil?
      yield 
      Sync[self].activate_queued unless Sync[self].nil?
    end

    def initialize_clock(tempo_or_input, resolution, options = {}, &block)
      @clock = Topaz::Tempo.new(tempo_or_input, :midi => options[:outputs]) 
      @clock.interval = @clock.interval * (resolution / @clock.interval)
      @clock.on_tick { tick(&block) }
    end
  end
end
