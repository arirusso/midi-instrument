require "helper"

class MIDISequencerTest < Test::Unit::TestCase
  
  def test_mute
    seq = DiamondEngine::MIDISequencer.new(175, :sequence => TestHelper::StubSequence.new)    
    assert_equal(false, seq.muted?)       
    seq.mute = true
    assert_equal(true, seq.muted?)
    seq.mute = false
    assert_equal(false, seq.muted?)
    seq.toggle_mute
    assert_equal(true, seq.muted?)
  end
  
  def test_output_processor
    seq = DiamondEngine::MIDISequencer.new(175)
    seq.output_process << MIDIFX::Limit.new(:channel, 10)
    results = seq.send(:process_output, [MIDIMessage::NoteOn["C4"].new(10, 100)])
    assert_equal(10, results.first.channel)     
    results = seq.send(:process_output, [MIDIMessage::NoteOn["C4"].new(0, 100)])
    assert_equal(10, results.first.channel)
  end
  
end
