#!/usr/bin/env ruby
module Inst
  
  class ProcessChain
    
    def method_missing(m, *a, &b)
      @processors.respond_to?(m) ? @processors.send(m, *a, &b) : super
    end
    
    def initialize
      @processors = []
    end
    
    def process(msgs)
      @processors.map { |processor| processor.process([msgs].flatten) }.flatten.compact
    end
          
  end
  
end
