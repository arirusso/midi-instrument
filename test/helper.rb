#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'test/unit'
require 'diamond-engine'

module TestHelper
  
  def self.select_devices
    $test_device ||= {}
    { :input => UniMIDI::Input, :output => UniMIDI::Output }.each do |type, klass|
      $test_device[type] = klass.gets
    end
  end
  
  class StubSequence
    
    def pending_note_offs
      []
    end
    
  end
  
  class StubOutput
    
    attr_reader :cache
    
    def initialize
      @cache = []
    end
    
    def type
      :output
    end
    
    def puts(a)
      @cache += a
    end
    
  end
     
end

TestHelper.select_devices