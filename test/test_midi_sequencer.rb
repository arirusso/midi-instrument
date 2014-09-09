require "helper"

class DiamondEngine::MIDISequencerTest < Test::Unit::TestCase
  
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
    
end
