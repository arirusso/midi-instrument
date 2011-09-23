#!/usr/bin/env ruby

require 'helper'

class SequencerStateTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
  
  def test_reset_pointer
    s = SequencerState.new
    assert_equal(0, s.pointer)
    s.pointer = 10
    assert_equal(10, s.pointer)
    s.reset_pointer
    assert_equal(0, s.pointer)
  end
  
end