#!/usr/bin/env ruby

require 'helper'

class MIDISequencerTest < Test::Unit::TestCase

  include DiamondEngine
  include MIDIMessage
  include TestHelper
  
  def test_mute
    seq = MIDISequencer.new(175, :sequence => StubSequence.new)    
    assert_equal(false, seq.muted?)       
    seq.mute = true
    assert_equal(true, seq.muted?)
    seq.mute = false
    assert_equal(false, seq.muted?)
    seq.toggle_mute
    assert_equal(true, seq.muted?)
  end
  
  def test_output_processor
    seq = MIDISequencer.new(175)
    seq.output_process << Process::Limit.new(:channel, 10)
    results = seq.send(:process_output, [NoteOn["C4"].new(10, 100)])
    assert_equal(10, results.first.channel)     
    results = seq.send(:process_output, [NoteOn["C4"].new(0, 100)])
    assert_equal(10, results.first.channel)
  end
  
end