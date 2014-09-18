require "helper"

class MIDIInstrument::InputTest < Test::Unit::TestCase

  include Mocha::ParameterMatchers

  context "Input" do

    setup do
      @input = MIDIInstrument::Input.new
    end

    context "#receive" do

      should "add callback" do
        match = { :class => MIDIMessage::NoteOn }
        block = proc { puts "hello" }
        MIDIInstrument::Listener.any_instance.expects(:receive).once.with(match).yields(block)
        result = @input.receive(match, &block)
        assert_equal @input, result
      end
      
    end

    context "#add" do

      should "accept strings" do
        MIDIInstrument::Listener.any_instance.expects(:add).once.with(is_a(MIDIMessage::NoteOn), is_a(MIDIMessage::NoteOn), is_a(MIDIMessage::NoteOn))
        @input.add("A3", "B4", "C5")
      end

      should "accept MIDI messages" do
        MIDIInstrument::Listener.any_instance.expects(:add).once.with(is_a(MIDIMessage::NoteOn), is_a(MIDIMessage::NoteOn), is_a(MIDIMessage::NoteOn))
        @input.add(MIDIMessage::NoteOn["C3"].new(3, 100), MIDIMessage::NoteOn["B4"].new(5, 100), MIDIMessage::NoteOn["D7"].new(7, 100))
      end

      should "not suppress unknown objects" do
        MIDIInstrument::Listener.any_instance.expects(:add).never
        assert_raise(NoMethodError) { @input.add("hello", "how", "are", "you") }
      end

    end

    context "#omni" do
      
      should "not have a receive channel" do
        assert_nil @input.instance_variable_get("@channel_filter")
        @input.channel = 4
        assert_equal 4, @input.channel
        @input.omni
        assert_nil @input.channel
        assert_nil @input.instance_variable_get("@channel_filter")
      end

    end

    context "#channel=" do

      should "set channel" do
        @input.channel = 3
        assert_equal 3, @input.channel
      end

      should "unset channel" do
        @input.channel = 3
        assert_equal 3, @input.channel
        @input.channel = nil
        assert_nil @input.channel
      end

    end

    context "#devices=" do

      should "replace devices" do
        assert_empty @input.devices
        inputs = UniMIDI::Input.all
        @input.devices = inputs
        assert_equal inputs, @input.devices
      end

    end

  end

end


