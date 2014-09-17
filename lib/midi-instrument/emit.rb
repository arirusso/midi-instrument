module MIDIInstrument

  # Send MIDI messages
  module Emit

    def self.included(base)
      base.send(:attr_reader, :outputs, :transmit_channel)
      base.send(:attr_writer, :mute)
      base.send(:alias_method, :tx_channel, :transmit_channel)
    end

    # Set the output to convert all emitted notes to a specific channel
    # @param [Fixnum, nil] channel
    # @return [Boolean]
    def transmit_channel=(channel)
      @output_filter = if channel.nil?
        channel
      else
        MIDIFX::Limit.new(:channel, channel, :name => :output_channel)
      end
      @transmit_channel = channel
      true
    end
    alias_method :tx_channel=, :transmit_channel=

    # Emit messages
    # @param [*Fixnum, *MIDIMessage::NoteOn, *MIDIMessage::NoteOff, *String] args
    # @return [Array<Object>]
    def puts(*args)
      data = [args.dup].flatten
      messages = Message.to_messages(*data)
      bytes = if messages.nil?
        data # array of hex numbers
      else
        filter_output(messages).map(&:to_bytes).flatten
      end
      @outputs.map { |output| output.puts(*bytes) } if !@mute
    end

    def toggle_mute
      @mute = !@mute
    end

    def mute
      @mute = true
    end

    def unmute
      @mute = false
    end

    def mute?
      @mute
    end

    private

    # Filter messages for output
    # @param [Array<MIDIMessage::ChannelMessage>] messages
    # @return [Array<MIDIMessage::ChannelMessage>] 
    def filter_output(messages)
      if @output_filter.nil?
        messages
      else
        messages.map { |message| @output_filter.process(message) }
      end
    end

    def initialize_emit(options = {})
      @mute = false
      @outputs = []
    end

  end

end
