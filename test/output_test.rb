require "helper"

class MIDIInstrument::OutputTest < Minitest::Test

  include Mocha::ParameterMatchers

  context "Output" do

    setup do
      @output = MIDIInstrument::Output.new
    end

    context "#puts" do

      setup do
        @output.devices << Object.new
      end

      should "output string notes" do
        names = ["A-1", "C#4", "F#5", "D6"]
        @output.devices.first.expects(:puts).times(1)
        result = @output.puts(*names)
      end

      should "output MIDI messages" do
        @output.devices.first.expects(:puts).times(1)
        result = @output.puts(MIDIMessage::NoteOn["C3"].new(0, 100), MIDIMessage::NoteOn["D3"].new(0, 110))
      end

      should "output to multiple devices" do
        4.times do
          @output.devices << Object.new
        end
        names = ["A-1", "C#4", "F#5", "D6"]
        @output.devices.each { |device| device.expects(:puts).once }
        result = @output.puts(*names)
      end

    end

    context "#mute" do

      setup do
        @output.devices << Object.new
      end

      should "output when not muted" do
        names = ["A-1", "C#4", "F#5", "D6"]
        refute @output.mute?
        @output.devices.first.expects(:puts).times(1)
        result = @output.puts(*names)
      end

      should "not output when muted" do
        names = ["A-1", "C#4", "F#5", "D6"]
        @output.mute
        assert @output.mute?
        @output.devices.first.expects(:puts).never
        result = @output.puts(*names)
      end

    end

    context "#channel=" do

      should "have filter when channel is specified" do
        assert_nil @output.instance_variable_get("@channel_filter")
        @output.channel = 3
        refute_nil @output.instance_variable_get("@channel_filter")
        assert_equal 3, @output.channel
      end

      should "not have filter when channel is nil" do
        @output.channel = 3
        refute_nil @output.instance_variable_get("@channel_filter")
        assert_equal 3, @output.channel
        @output.channel = nil
        assert_nil @output.instance_variable_get("@channel_filter")
        assert_nil @output.channel
      end

      should "filter MIDI message channels when outputting" do
        @output.channel = 3
        result = @output.send(:filter_output, [MIDIMessage::NoteOn["C3"].new(0, 100), MIDIMessage::NoteOn["D3"].new(0, 110)])
        assert result.all? { |message| message.channel == 3 }
      end


    end

    context "#devices=" do

      should "replace devices" do
        assert_empty @output.devices
        outputs = UniMIDI::Output.all
        @output.devices = outputs
        assert_equal outputs, @output.devices
      end

    end

  end

end
