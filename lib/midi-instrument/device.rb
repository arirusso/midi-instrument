module MIDIInstrument

  # Manage MIDI Devices
  module Device

    extend self

    # Partition UniMIDI devices into a hash of inputs and outputs
    # @param [Array<UniMIDI::Input, UniMIDI::Output>, UniMIDI::Input, UniMIDI::Output] devices Input or output device(s).
    # @return [Hash] Partitioned arrays of inputs and outputs.
    def partition(devices)
      devices = [(devices || [])].flatten
      outputs = devices.select { |device| device.respond_to?(:puts) }
      inputs = devices.find_all { |d| d.respond_to?(:type) && d.type == :input && d.respond_to?(:gets) }.compact
      {
        :input => inputs,
        :output => outputs
      }
    end
    
  end
end
