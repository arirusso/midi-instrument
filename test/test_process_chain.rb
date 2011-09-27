#!/usr/bin/env ruby

require 'helper'

class ProcessChainTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
  
  def test_process
    p = ProcessChain.new
    p << Process::Limit.new(:channel, 5)
    msg = NoteOn["C4"].new(10, 100)
    assert_equal(10, msg.channel)   
    p.process(msg)  
    assert_equal(5, msg.channel)   
  end
  
  def test_process_array
    p = ProcessChain.new
    p << Process::Limit.new(:channel, 5)
    p << Process::Limit.new(:velocity, 30)
    msgs = []
    msgs << NoteOn["C4"].new(10, 100)
    msgs << NoteOn["C4"].new(9, 110)
    assert_equal(10, msgs.first.channel)   
    assert_equal(100, msgs.first.velocity)
    result = p.process(msgs)  
    assert_equal(5, result.first.channel)      
    assert_equal(30, result.first.velocity)
    assert_equal(5, result.last.channel)      
    assert_equal(30, result.last.velocity)
  end
      
end