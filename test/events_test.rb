require "helper"

class SequencerCallbacksTest < Test::Unit::TestCase
  
  def test_rest_when
    output = $test_device[:output]
    seq = DiamondEngine::MIDISequencer.new(175, :midi => output)
    seq.rest_when Proc.new { |state| state.pointer == 0 }
    assert_not_nil seq.events.rest_when
    assert seq.state.rest?(&seq.events.rest_when)
  end
  
  def test_reset_when
    output = $test_device[:output]
    seq = DiamondEngine::MIDISequencer.new(175, :midi => output)
    seq.reset_when Proc.new { |state| state.pointer == 0 }
    assert_not_nil seq.events.reset_when
    assert seq.state.reset?(&seq.events.reset_when)
  end
  
  def test_on_start
    
  end
  
  def test_on_stop
    
  end
  
  def test_on_tick
    
  end
    
end
