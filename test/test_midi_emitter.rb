#!/usr/bin/env ruby

require 'helper'

class MIDIEmitterTest < Test::Unit::TestCase

  include Inst
  include MIDIMessage
  include TestHelper
  
  def test_toggle_muted
    e = MIDIEmitter.new
    assert_equal(false, e.muted?)
    e.toggle_mute
    assert_equal(true, e.muted?)
    e.toggle_mute
    assert_equal(false, e.muted?)
  end
  
  def test_mute_unmute
    e = MIDIEmitter.new
    assert_equal(false, e.muted?)
    e.mute
    assert_equal(true, e.muted?)
    e.mute
    assert_equal(true, e.muted?)
    e.unmute
    assert_equal(false, e.muted?)    
    e.unmute
    assert_equal(false, e.muted?)  
  end
  
  def test_pass_in_destination
    output = $test_device[:output]
    e = MIDIEmitter.new(output)
    assert_equal($test_device[:output], e.destinations.first)    
  end
    
  def test_add_destination
    output = $test_device[:output]
    e = MIDIEmitter.new
    e.add_destination(output)
    assert_equal($test_device[:output], e.destinations.first)
  end
  
  def test_add_remove_destination    
    output = $test_device[:output]
    e = MIDIEmitter.new
    e.add_destination(output)
    assert_equal($test_device[:output], e.destinations.first)
    e.remove_destination(output)
    assert_equal(nil, e.destinations.first)       
  end
  
  def test_quiet
    output = StubOutput.new
    e = MIDIEmitter.new(output)
    e.quiet!
    assert_equal((2048 * 3), output.cache.size)
  end
  
  def test_emit
    output = StubOutput.new
    e = MIDIEmitter.new(output)
    e.emit(MIDIMessage.parse(0x90, 0x40, 0x40))
    assert_equal([0x90, 0x40, 0x40], output.cache)
  end
  
end