module DiamondEngine
  
  class ProcessChain
    
    def method_missing(method, *args, &block)
      if @processors.respond_to?(method)
        @processors.send(method, *args, &block)
      else
        super
      end
    end
    
    def initialize
      @processors = []
    end
    
    # run all @processors on <em>msgs</em>
    def process(messages)
      if @processors.empty?
        messages
      else
        processed = @processors.map do |processor|
          [messages].flatten.map { |message| processor.process(message) }
        end
        processed.flatten.compact
      end
    end
    
    # find the processor with the name <em>name</em>
    def find_by_name(name)
      @processors.find { |process| process.name == name }
    end
          
  end
  
end
