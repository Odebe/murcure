module Murcure
  class MessageHandler
    
    @clients_storage : Murcure::ClientStorage
    @rooms_storage : Murcure::RoomStorage

    def initialize(@clients_storage, @rooms_storage); end

    def call(message : Murcure::Messages::Base)
      process_ping(message) && return if message.type == :ping 

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
        proto_m = Murcure::MessageBuilder.new.process_channel_state_message(room)
        message = Murcure::Messages::Output.new(:channel_state, proto_m, message.uuid)        
        client_channel.send(message)
      end
    end

    private def process_ping(message : Murcure::Messages::Base)
      puts message.inspect
      proto_m = Murcure::MessageBuilder.new.process_ping_message
      message = Murcure::Messages::Output.new(:ping, proto_m, message.uuid)        
      client_channel = @clients_storage.channel(message.uuid).not_nil!      
      client_channel.send(message)
    end

    private def process_version(message : Murcure::Messages::Base)
      proto = message
      return unless proto.is_a?(Murcure::Protos::Version)

      client = @clients_storage.get_client(message.uuid)
      return if client.nil?
      
      @clients_storage.update_attr(message.uuid, :version, proto.version)
      @clients_storage.update_attr(message.uuid, :release, proto.release)
      @clients_storage.update_attr(message.uuid, :os, proto.os)
      @clients_storage.update_attr(message.uuid, :os_version, proto.os_version)
      
      client[:machine].fire(:add_version)
    end

    private def process_auth(message : Murcure::Messages::Base)
      proto = message.proto
      return unless proto.is_a?(Murcure::Protos::Authenticate)

      client = @clients_storage.get_client(message.uuid)
      return if client.nil?
      
      @clients_storage.update_attr(message.uuid, :username, proto.username)
      @clients_storage.update_attr(message.uuid, :password, proto.password)
      @clients_storage.update_attr(message.uuid, :tokens, proto.tokens)

      client[:machine].fire(:add_auth)
    end
  end
end
