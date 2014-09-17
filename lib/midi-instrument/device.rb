module MIDIInstrument

  # Manage MIDI Devices
  module Device

    extend self

    # Partition UniMIDI devices into a hash of inputs and outputs
    # @param [Array<UniMIDI::Input, UniMIDI::Output>, UniMIDI::Input, UniMIDI::Output] devices Input or output device(s).
    # @return [Hash] Partitioned arrays of inputs and outputs.
    def partition(devices)
      devices = [(devices || [])].flatten
      outputs = devices.select { |device| output?(device) }
      inputs = devices.select { |device| input?(device) }
      {
        :input => inputs,
        :output => outputs
      }
    end

    private

    # Is this device an output?
    # @param [UniMIDI::Output, Object] device
    # @return [Boolean]
    def output?(device)
      device.respond_to?(:puts)
    end

    # Is this device an input?
    # @param [UniMIDI::Input, Object] device
    # @return [Boolean]
    def input?(device)
      device.respond_to?(:type) && device.type == :input && device.respond_to?(:gets)
    end
    
  end
end
