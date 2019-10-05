module Murcure
  class MessageHandler
    
    @clients_storage : Murcure::ClientStorage
    @rooms_storage : Murcure::RoomStorage

    def initialize(@clients_storage, @rooms_storage); end

    def call(message : Murcure::Message)
      process_ping(message) && return if message.subtype == :ping 

      sender = @clients_storage.get_client(message.uuid)
      return if sender.nil? # TODO: raise error

      puts sender[:attrs].inspect
      puts @rooms_storage.inspect

      process_by_state(sender, message)
    end

    private def process_by_state(sender, message)
      case sender[:machine].state
      when :connected
        case message.type
        when :version
          process_version(message)
        when :auth
          process_auth(message)
        end
        process_by_state(sender, message) if sender[:machine].auth_ended?
      when :sync
        send_channels_state(message, sender)
        # send_users_state(sender)
      when :active
        # TODO
      end
    end

    private def send_channels_state(message, sender)
      client_channel = @clients_storage.channel(message.uuid).not_nil!
      @rooms_storage.rooms.values.each do |room|
        message = Murcure::Message.new(:cmd, :channel_state, nil, room, nil)
        client_channel.send(message)
      end
    end

    private def process_version(message : Murcure::Message)
      proto = message.proto_struct
      return unless proto.is_a?(Murcure::Protos::Version)

      client = @clients_storage.get_client(message.uuid)
      return if client.nil?
      
      @clients_storage.update_attr(message.uuid, :version, proto.version)
      @clients_storage.update_attr(message.uuid, :release, proto.release)
      @clients_storage.update_attr(message.uuid, :os, proto.os)
      @clients_storage.update_attr(message.uuid, :os_version, proto.os_version)
      
      client[:machine].fire(:add_version)
    end

    private def process_auth(message : Murcure::Message)
      proto = message.proto_struct
      return unless proto.is_a?(Murcure::Protos::Authenticate)

      client = @clients_storage.get_client(message.uuid)
      return if client.nil?
      
      @clients_storage.update_attr(message.uuid, :username, proto.username)
      @clients_storage.update_attr(message.uuid, :password, proto.password)
      @clients_storage.update_attr(message.uuid, :tokens, proto.tokens)

      client[:machine].fire(:add_auth)
    end

    private def process_ping(message : Murcure::Message)
      @clients_storage.channel(message.uuid).send(message)
    end
  end
end
