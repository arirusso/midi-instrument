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
        base.send(:def_delegator, :events, :reset_when=, :reset_when)
        base.send(:def_delegator, :events, :rest_when=, :rest_when)
        base.send(:def_delegators, :events, :on_start, :on_start)
        base.send(:def_delegators, :events, :on_stop, :on_stop)
        base.send(:def_delegators, :events, :on_tick, :on_tick)
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
        base.send(:def_delegator, :state, :reset_pointer, :reset)
        base.send(:def_delegators, :state, :running?)
        base.send(:alias_method, :running, :running?)
      end

    end

  end
end
