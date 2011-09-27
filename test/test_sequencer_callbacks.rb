#!/usr/bin/env ruby

require 'helper'

class SequencerCallbacksTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
  
  def test_rest_when
    output = $test_device[:output]
    seq = MIDISequencer.new(175, :midi => output)
    seq.rest_when { |state| state.pointer == 0 }
    assert_equal(true, seq.rest?)
  end
  
  def test_reset_when
    output = $test_device[:output]
    seq = MIDISequencer.new(175, :midi => output)
    seq.rest_when { |state| state.pointer == 0 }
    assert_equal(true, seq.rest?)
  end
  
  def test_on_start
    
  end
  
  def test_on_stop
    
  end
  
  def test_on_tick
    
  end
    
end