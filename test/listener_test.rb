require "helper"

class MIDIInstrument::ListenerTest < Minitest::Test

  context "Listener" do

    setup do
      MIDIInstrument::Listener.any_instance.unstub(:add)
      @listener = MIDIInstrument::Listener.new(Object.new)
    end

    context "#add" do

      should "output hashes with timestamps" do
        notes = [
          MIDIMessage::NoteOn["C3"].new(3, 100),
          MIDIMessage::NoteOn["B4"].new(5, 100),
          MIDIMessage::NoteOn["D7"].new(7, 100)
        ]
        result = @listener.add(*notes)
        refute_nil result
        refute_empty result
        assert result.all? { |r| r.kind_of?(Hash) }
        refute result.any? { |r| r[:timestamp].nil? }
      end

    end

  end

end
