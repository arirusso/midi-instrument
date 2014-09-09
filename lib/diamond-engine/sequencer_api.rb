module DiamondEngine

  module SequencerAPI

    module Clock

      def self.included(base)
        base.extend(Forwardable)
        base.send(:def_delegators, :@clock, :join, :tempo, :tempo=)
        base.send(:alias_method, :focus, :join)
      end

    end

    module Emitter

      def self.included(base)
        base.extend(Forwardable)
        base.send(:def_delegator, :@emitter, :destinations, :midi_destinations)
        base.send(:def_delegator, :@emitter, :clock_destinations, :midi_clock_destinations)
        base.send(:def_delegators, :@emitter, :muted?, :toggle_mute, :mute, :mute=)
      end

    end

    module Events

      def self.included(base)
        base.extend(Forwardable)
        base.send(:def_delegator, :@events, :reset_when=, :reset_when)
        base.send(:def_delegator, :@events, :rest_when=, :rest_when)
        base.send(:def_delegators, :@events, :on_start, :on_start)
        base.send(:def_delegators, :@events, :on_stop, :on_stop)
        base.send(:def_delegators, :@events, :on_tick, :on_tick)
      end

    end

    module MIDIReceive

      def receive_midi(name, match = {}, &block)
        @midi_listener.receive_midi(self, name, match, &block)
      end

      def add_midi_source(source)
        @midi_listener.add_source(source)
      end
      alias_method :add_midi_sources, :add_midi_source

      def remove_midi_source(source)
        @midi_listener.remove_source(source)
      end
      alias_method :remove_midi_sources, :remove_midi_source

      def midi_sources
        @midi_listener.sources
      end

    end

    module State

      def self.included(base)
        base.extend(Forwardable)
        base.send(:def_delegator, :@state, :reset_pointer, :reset)
        base.send(:def_delegators, :@state, :running?)
        base.send(:alias_method, :running, :running?)
      end

    end

    module Sync

      # Is this instrument master of the given syncable?
      def has_sync_slave?(syncable)
        !DiamondEngine::Sync[self].nil? && DiamondEngine::Sync[self].slave?(syncable)
      end
      alias_method :syncs?, :has_sync_slave?

      # Is this instrument slave to the given syncable?
      def has_sync_master?(syncable)
        !DiamondEngine::Sync[syncable].nil? && DiamondEngine::Sync[syncable].slave?(self)
      end
      alias_method :synced_to?, :has_sync_master?

      # Is this instrument synced with the given syncable either as master or slave?
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

    end

  end
end
