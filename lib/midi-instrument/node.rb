module MIDIInstrument

  class Node

    include Emit
    include Listen

    def initialize(options = {})
      initialize_emit(options)
      initialize_listen(options)
    end

  end

end

