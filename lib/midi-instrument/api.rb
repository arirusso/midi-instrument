module MIDIInstrument

  module API

    def self.included(base)
      base.send(:extend, Forwardable)
      base.send(:def_delegators, :@input, :omni_on)
      base.send(:def_delegators, :@output, :mute, :toggle_mute, :mute=, :muted?, :mute?)
    end

  end

end

