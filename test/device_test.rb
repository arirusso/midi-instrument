require "helper"

class MIDIInstrument::DeviceTest < Test::Unit::TestCase

  context "Device" do

    context ".partition" do

      should "partition some devices" do
        inputs = UniMIDI::Input.all
        outputs = UniMIDI::Output.all
        devices = inputs + outputs
        result = MIDIInstrument::Device.partition(devices)
        assert_not_nil result
        assert result.kind_of?(Hash)
        assert_not_nil result[:input]
        assert_not_nil result[:output]
        assert_equal inputs, result[:input]
        assert_equal outputs, result[:output]
      end

     end
  end

end

