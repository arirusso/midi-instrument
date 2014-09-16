module MIDIInstrument

  class Node

    include Emit
    include Listen

    def initialize
      initialize_emit
      initialize_listen
    end

  end

end

