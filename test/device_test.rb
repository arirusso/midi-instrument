require "helper"

class MIDIInstrument::DeviceTest < Minitest::Test

  context "Device" do

    context ".partition" do

      should "partition some devices" do
        inputs = UniMIDI::Input.all
        outputs = UniMIDI::Output.all
        devices = inputs + outputs
        result = MIDIInstrument::Device.partition(devices)
        refute_nil result
        assert result.kind_of?(Hash)
        refute_nil result[:input]
        refute_nil result[:output]
        assert_equal inputs, result[:input]
        assert_equal outputs, result[:output]
      end

     end
  end

end
