#!/usr/bin/env ruby

require 'helper'

class SyncableTest < Test::Unit::TestCase

  include DiamondEngine
  include MIDIMessage
  include TestHelper
  
  def test_sync
    s1 = MIDISequencer.new(120)
    s2 = MIDISequencer.new(127)
    assert_equal(false, s1.sync?(s2))
    s1.sync(s2)
    assert_equal(true, s1.sync?(s2))
  end

  def test_sync_to

  end
  
  def test_unsync
    
  end
  
  def test_unsync_from
    
  end
  
  def test_clock_pause
    
  end
  
  def test_booleans
    
  end
    
end