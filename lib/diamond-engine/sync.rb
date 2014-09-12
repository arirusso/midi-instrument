module DiamondEngine
  
  class Sync

    class << self

      include Enumerable

      def activate_queued(syncable, options = {})
        !Sync[syncable].nil? && Sync[syncable].activate_queued(options)
      end

      def sync
        @sync ||= {}
      end

      def each(&block)
        sync.values.each(&block)
      end

      def [](master)
        sync[master]
      end
      
      def []=(master, sync)
        self.sync[master] = sync
      end

    end
    
    attr_reader :master, # the master sequencer that controls the tempo
                :slave_queue, # a queue of sequencers to begin sync for on the next beat
                :slaves # sequencers that are controlled by the master
    
    def initialize(master, options = {})
      @master = master
      @slave_queue = {}
      @slaves = options[:slaves] || [options[:slave]].flatten
    end
    
    # Sync the given syncable to self
    # pass :now => true to queue the sync to happen immediately
    # otherwise the sync will happen at the beginning of self's next sequence
    def add(syncable, options = {})
      @slave_queue[syncable] = options[:now] || false
      true               
    end
    
    # Is the given syncable a slave?
    def slave?(syncable)
      @slaves.include?(syncable) || @slave_queue.include?(syncable)
    end

    # Is the given syncable master or slave?
    def include?(syncable)
      slave?(syncable) || @master == syncable
    end
    
    # Stop sending sync to syncable
    def remove(syncable)
      @slaves.delete(syncable)
      @slave_queue.delete(syncable)
      syncable.clock.unpause
      true
    end
    
    def stop
      @slaves.each(&:stop)
    end
    
    def start
      @slaves.each(&:start)
    end
    
    # You don't truly hear sync until slaves are moved from the queue to the slaves set 
    def activate_queued(options = {})
      updated = []
      @slave_queue.each do |syncable, sync_now|
        if sync_now || options[:immediate]
          @slaves << syncable
          syncable.start(:suppress_clock => true) unless syncable.running?
          syncable.clock.pause
          @slave_queue.delete(syncable)
          updated << syncable
        end
      end
      updated
    end
          
  end
  
end
