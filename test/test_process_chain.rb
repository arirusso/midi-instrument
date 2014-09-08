require "helper"

class ProcessChainTest < Test::Unit::TestCase
  
  def test_process
    p = DiamondEngine::ProcessChain.new
    p << MIDIFX::Limit.new(:channel, 5)
    msg = MIDIMessage::NoteOn["C4"].new(10, 100)
    assert_equal(10, msg.channel)   
    p.process(msg)  
    assert_equal(5, msg.channel)   
  end
  
  def test_process_array
    p = DiamondEngine::ProcessChain.new
    p << MIDIFX::Limit.new(:channel, 5)
    p << MIDIFX::Limit.new(:velocity, 30)
    msgs = []
    msgs << MIDIMessage::NoteOn["C4"].new(10, 100)
    msgs << MIDIMessage::NoteOn["C4"].new(9, 110)
    assert_equal(10, msgs.first.channel)   
    assert_equal(100, msgs.first.velocity)
    result = p.process(msgs)  
    assert_equal(5, result.first.channel)      
    assert_equal(30, result.first.velocity)
    assert_equal(5, result.last.channel)      
    assert_equal(30, result.last.velocity)
  end
      
end
