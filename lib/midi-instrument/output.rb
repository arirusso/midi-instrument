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
        nil
      else
        MIDIFX::Limit.new(:channel, channel, :name => :output_channel)
      end
      @channel = channel
      true
    end

    # Emit messages
    # @param [*Fixnum, *MIDIMessage::NoteOn, *MIDIMessage::NoteOff, *String] args
    # @return [Array<Fixnum>]
    def puts(*args)
      messages = Message.to_messages(*args)
      messages = filter_output(messages)
      bytes = messages.map(&:to_bytes)
      if !@mute
        @devices.each { |output| output.puts(*bytes) }
      end
      bytes
    end
    alias_method :<<, :puts

    # Toggle muted output
    # @return [Boolean]
    def toggle_mute
      @mute = !@mute
    end

    # Mute the output
    # @return [TrueClass]
    def mute
      @mute = true
    end

    # Un-mute the output
    # @return [FalseClass]
    def unmute
      @mute = false
    end

    # Is the output muted?
    # @return [Boolean]
    def mute?
      @mute
    end

    # Replace the devices with the given devices
    # @param [Array<UniMIDI::Outputs>] devices
    # @return [OutputContainer]
    def devices=(devices)
      @devices.clear
      @devices += devices
      @devices
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
