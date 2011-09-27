#!/usr/bin/env ruby
module Inst
  
  class ProcessChain
    
    def method_missing(m, *a, &b)
      @processors.respond_to?(m) ? @processors.send(m, *a, &b) : super
    end
    
    def initialize
      @processors = []
    end
    
    # run all @processors on <em>msgs</em>
    def process(msgs)
      @processors.map { |processor| processor.process([msgs].flatten) }.flatten.compact
    end
    
    # find the processor with the name <em>name</em>
    def find_by_name(name)
      @processors.find { |process| process.name == name }
    end
          
  end
  
end
