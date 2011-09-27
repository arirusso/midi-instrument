#!/usr/bin/env ruby

require 'helper'

class MIDISequencerTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
  
  def test_mute
    arp = Arpeggiator.new(175)    
    assert_equal(false, arp.muted?)       
    arp.mute
    assert_equal(true, arp.muted?)
    arp.unmute
    assert_equal(false, arp.muted?)
    arp.toggle_mute
    assert_equal(true, arp.muted?)
  end
  
end