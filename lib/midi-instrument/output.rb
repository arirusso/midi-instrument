module MIDIInstrument

  # Send MIDI messages
  class Output

    attr_reader :devices, :channel
    attr_writer :mute

    def initialize
      @channel = nil
      @channel_filter = nil
      @mute = false
      @devices = []
    end

    # Set the output to convert all emitted notes to a specific channel
    # @param [Fixnum, nil] channel
    # @return [Boolean]
    def channel=(channel)
      @channel_filter = if channel.nil?
        channel
      else
        MIDIFX::Limit.new(:channel, channel, :name => :output_channel)
      end
      @channel = channel
      true
    end

    # Emit messages
    # @param [*Fixnum, *MIDIMessage::NoteOn, *MIDIMessage::NoteOff, *String] args
    # @return [Emit]
    def puts(*args)
      data = [args.dup].flatten
      messages = Message.to_messages(*data)
      bytes = if messages.nil?
        data # array of hex numbers
      else
        filter_output(messages).map(&:to_bytes).flatten
      end
      @devices.map { |output| output.puts(*bytes) } if !@mute
      messages  
    end
    alias_method :<<, :puts

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
      if @channel_filter.nil?
        messages
      else
        messages.map { |message| @channel_filter.process(message) }
      end
    end

  end

end
