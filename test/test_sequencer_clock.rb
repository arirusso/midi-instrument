#!/usr/bin/env ruby

require 'helper'

class SequencerClockTest < Test::Unit::TestCase

  include DiamondEngine
  include MIDIMessage
  include TestHelper
  
  def test_tick
    i = 0
    s = SequencerClock.new(70, 20) { i += 1 }
    assert_equal(0, i)
    s.start(:background => true)
    sleep(1)
    s.stop
    assert_equal(5, i)
  end

  def test_add_destination
    o = StubOutput.new
    s = SequencerClock.new(60, 20) { }
    s.start(:background => true)
    s.add_midi_clock_destinations(o)
    sleep(1)
    s.stop
    assert_equal(false, o.cache.empty?)
  end
    
end