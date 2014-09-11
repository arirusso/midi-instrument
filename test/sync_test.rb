require "helper"

class DiamondEngine::SyncTest < Test::Unit::TestCase
  
  def test_add
    seq1 = DiamondEngine::MIDISequencer.new(110)
    seq2 = DiamondEngine::MIDISequencer.new(120)
    sync = DiamondEngine::Sync.new(seq1)

    assert sync.include?(seq1)
    refute sync.slave?(seq1)
    refute sync.include?(seq2)

    sync.add(seq2)

    assert sync.include?(seq2)
    assert sync.slave?(seq2)
  end

  def test_remove
    seq1 = DiamondEngine::MIDISequencer.new(110)
    seq2 = DiamondEngine::MIDISequencer.new(120)
    sync = DiamondEngine::Sync.new(seq1, :slave => seq2)

    assert sync.include?(seq1)
    assert sync.include?(seq2)
    refute sync.slave?(seq1)

    sync.remove(seq2)

    assert sync.include?(seq1)
    refute sync.include?(seq2)
  end
  
  def test_activate_now
    
  end
  
  def test_activate_later
    
  end
  
end
