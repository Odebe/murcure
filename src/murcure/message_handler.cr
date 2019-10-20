module Murcure
  class MessageHandler
    
    @clients_storage : Murcure::ClientStorage
    @rooms_storage : Murcure::RoomStorage

    def initialize(@clients_storage, @rooms_storage); end

    def call(message : Murcure::Messages::Base)
      process_ping(message) && return if message.type == :ping 

      sender = @clients_storage.get_client(message.session_id)
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
        send_channels_state(message)
        send_users_state(message)
      when :active
        # TODO
      end
    end

    private def send_users_state(message)
      client_channel = @clients_storage.channel(message.session_id).not_nil!
      @clients_storage.clients.each do |client|
        proto_m = Murcure::MessageBuilder.new.process_user_state_message(client)
        message = Murcure::Messages::Output.new(:user_state, proto_m, message.session_id)        
        client_channel.send(message)
      end
    end

    private def send_channels_state(message)
      client_channel = @clients_storage.channel(message.session_id).not_nil!
      @rooms_storage.rooms.values.each do |room|
        proto_m = Murcure::MessageBuilder.new.process_channel_state_message(room)
        message = Murcure::Messages::Output.new(:channel_state, proto_m, message.session_id)        
        client_channel.send(message)
      end
    end

    private def process_ping(message : Murcure::Messages::Base)
      proto_m = Murcure::MessageBuilder.new.process_ping_message
      message = Murcure::Messages::Output.new(:ping, proto_m, message.session_id)
      client_channel = @clients_storage.channel(message.session_id).not_nil!      
      client_channel.send(message)
    end

    private def process_version(message : Murcure::Messages::Base)
      proto = message.proto
      return unless proto.is_a?(Murcure::Protos::Version)

      client = @clients_storage.get_client(message.session_id)
      return if client.nil?
      
      @clients_storage.update_attr(message.session_id, :version, proto.version)
      @clients_storage.update_attr(message.session_id, :release, proto.release)
      @clients_storage.update_attr(message.session_id, :os, proto.os)
      @clients_storage.update_attr(message.session_id, :os_version, proto.os_version)
      
      client[:machine].fire(:add_version)
    end

    private def process_auth(message : Murcure::Messages::Base)
      proto = message.proto
      return unless proto.is_a?(Murcure::Protos::Authenticate)

      client = @clients_storage.get_client(message.session_id)
      return if client.nil?
      
      @clients_storage.update_attr(message.session_id, :username, proto.username)
      @clients_storage.update_attr(message.session_id, :password, proto.password)
      @clients_storage.update_attr(message.session_id, :tokens, proto.tokens)

      client[:machine].fire(:add_auth)
    end
  end
end
