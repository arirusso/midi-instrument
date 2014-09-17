require "helper"

class MIDIInstrument::MessageTest < Test::Unit::TestCase

  context "Message" do

    context ".to_messages" do

      should "convert strings to note on messages" do
        names = ["A-1", "C#4", "F#5", "D6"]
        result = MIDIInstrument::Message.to_messages(*names)
        assert_not_nil result
        assert_not_empty result
        assert_equal names.size, result.size
        assert result.all? { |item| item.is_a?(MIDIMessage::NoteOn) }
        names.each_with_index { |name, i| assert_equal name, result[i].name }
      end

      should "pass MIDI messages" do
        names = ["A-1", "C#4", "F#5", "D6"]
        messages  = MIDIInstrument::Message.to_messages(*names)
        result = MIDIInstrument::Message.to_messages(*messages)
        assert_not_nil result
        assert_not_empty result
        messages.each_with_index { |message,i| assert_equal message.note, result[i].note }
      end

      should "return nil for unknowns" do
        assert_nil MIDIInstrument::Message.to_messages("bla", "blah")
      end

    end

    context ".to_bytes" do

      should "convert messages to bytes" do
        names = ["A-1", "C#4", "F#5", "D6"]
        messages  = MIDIInstrument::Message.to_messages(*names)
        result = MIDIInstrument::Message.to_bytes(*messages)
        assert_not_nil result
        assert_not_empty result
        assert result.all? { |item| item.is_a?(Fixnum) }
        assert_equal messages.map(&:to_a).flatten, result
      end

      should "convert strings to bytes" do
        names = ["A-1", "C#4", "F#5", "D6"]
        messages  = MIDIInstrument::Message.to_messages(*names)
        result = MIDIInstrument::Message.to_bytes(*names)
        assert_not_nil result
        assert_not_empty result
        assert result.all? { |item| item.is_a?(Fixnum) }
        assert_equal messages.map(&:to_a).flatten, result
      end

      should "pass bytes" do
        bytes = [144, 9, 100, 144, 61, 100, 144, 78, 100, 144, 86, 100]
        result = MIDIInstrument::Message.to_bytes(*bytes)
        assert_not_nil result
        assert_not_empty result
        assert result.all? { |item| item.is_a?(Fixnum) }
        assert_equal bytes, result
      end

      should "return nil for unknown" do
        assert_nil MIDIInstrument::Message.to_bytes("this", "is", "something", "weird", 4560)
      end

    end

    context ".to_note_ons" do

      should "convert strings to note ons" do
        names = ["A-1", "C#4", "F#5", "D6"]
        result = MIDIInstrument::Message.to_note_ons(*names)
        assert_not_nil result
        assert_not_empty result
        assert_equal names.size, result.size
        assert result.all? { |item| item.is_a?(MIDIMessage::NoteOn) }
        names.each_with_index { |name, i| assert_equal name, result[i].name }
      end

      should "pass note on messages" do
        names = ["A-1", "C#4", "F#5", "D6"]
        messages  = MIDIInstrument::Message.to_messages(*names)
        result = MIDIInstrument::Message.to_note_ons(*messages)
        assert_not_nil result
        assert_not_empty result
        messages.each_with_index { |message,i| assert_equal message.note, result[i].note }
      end

      should "return nil for unknowns" do
        result = MIDIInstrument::Message.to_note_ons("blah", "blah", 56904)
        assert_not_nil result
        assert_equal 3, result.size
        assert_empty result.compact
      end

    end
    
  end

end



