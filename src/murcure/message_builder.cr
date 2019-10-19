module Murcure
  class MessageBuilder

    def process_user_state_message(data)
      Murcure::Protos::UserState.new.tap do |m|
        m.session = data[:session_id].to_u32
        m.name = data[:attrs][:username].to_s
        m.channel_id = 0.to_u32
      end
    end

    def process_channel_state_message(data : Murcure::RoomStruct)
      Murcure::Protos::ChannelState.new.tap do |m|
        m.channel_id = data.id.to_u32
        m.name = data.name.to_s
      end
    end

    def process_server_sync_message(message)
      Murcure::Protos::ServerSync.new.tap do |m|
        m.session = message.session_id.to_u32
        m.welcome_text = "molodoi chelovek da vize pidir!!! BAN"
      end
    end

    def process_ping_message
      Murcure::Protos::Ping.new.tap do |m|
        m.timestamp = 123123.to_u64
      end
    end

    private def to_bytes(data : Protobuf::Message) : Bytes
      message = process_message(@type, data)

      message_memory = message.to_protobuf
      message_memory.rewind
      bytes = Bytes.new(message_memory.bytesize)
      message_memory.read(bytes)
      bytes
    end
  end
end
