module Murcure
  class MessageHandler
    
    @clients_storage : Murcure::ClientStorage
    @rooms_storage : Murcure::RoomStorage

    def initialize(@clients_storage, @rooms_storage); end

    def handle_message(message : Murcure::Messages::Base)
      process_ping(message) && return if message.type == :ping
      process_by_state(message)
    end

    def handle_error(message : Murcure::Messages::Error)
      process_error(message)
    end

    private def process_by_state(message)
      sender = @clients_storage.get_client(message.session_id).not_nil! 
      case sender.machine.state
      when :connected
        case message.type
        when :version
          process_version(message)
          sender.machine.fire(:add_version)     
        when :auth
          process_auth(message)
          sender.machine.fire(:add_auth)
        end
        process_by_state(message) if sender.machine.auth_ended?
      when :sync
        send_channels_state(message)
        send_users_state(message)
        send_server_sync(message)
        send_notify_new_user(message)
        sender.machine.fire(:activate)
      when :active
        process_active_messages(message)
        # TODO
      end
    end

    private def process_active_messages(message)
      case message.type
      when :text_message
        send_text_message(message)
      end
    end

    private def process_error(message : Murcure::Messages::Error)
      case message.type
      when :user_remove
        client = @clients_storage.get_client(message.session_id).not_nil!
        proto_m = Murcure::MessageBuilder.new.process_user_remove(client)
        new_message = Murcure::Messages::Output.new(:user_remove, proto_m, message.session_id) 

        @clients_storage.delete_client(message.session_id)        
        @clients_storage.clients.each do |another_client|
          client_channel = @clients_storage.channel(another_client.session_id).not_nil!       
          client_channel.send(new_message)
        end
        
        puts "User: #{message.session_id} disconnected!"
      end
    end
5
    private def send_notify_new_user(message)
      client = @clients_storage.get_client(message.session_id).not_nil!
      proto_m = Murcure::MessageBuilder.new.process_user_state_message(client)
      message = Murcure::Messages::Output.new(:user_state, proto_m, message.session_id) 

      @clients_storage.clients.reject { |c| c.session_id == message.session_id }.each do |another_client|
        client_channel = @clients_storage.channel(another_client.session_id).not_nil!       
        client_channel.send(message)
      end
    end

    private def send_text_message(message)
      proto_in = message.proto 
      return unless proto_in.is_a?(Murcure::Protos::TextMessage)

      client = @clients_storage.get_client(message.session_id).not_nil!
      client_rooms = @rooms_storage.client_rooms(client.session_id)

      struct_m = { sender: client, clients: [client], rooms: client_rooms, message: proto_in }
      proto_m = Murcure::MessageBuilder.new.process_text_message(struct_m)
      message = Murcure::Messages::Output.new(:text_message, proto_m, message.session_id)        
      
      @clients_storage.clients.reject { |c| c.session_id == message.session_id }.each do |client|
        client_channel = @clients_storage.channel(client.session_id).not_nil!       
        client_channel.send(message)
      end
    end

    private def send_server_sync(message)
      client_channel = @clients_storage.channel(message.session_id).not_nil!
      client = @clients_storage.get_client(message.session_id).not_nil!
      proto_m = Murcure::MessageBuilder.new.process_server_sync_message(client)
      message = Murcure::Messages::Output.new(:server_sync, proto_m, message.session_id)
      
      client_channel.send(message)
      client.machine.fire(:add_version)
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

      @clients_storage.update_attr(message.session_id, :version, proto.version)
      @clients_storage.update_attr(message.session_id, :release, proto.release)
      @clients_storage.update_attr(message.session_id, :os, proto.os)
      @clients_storage.update_attr(message.session_id, :os_version, proto.os_version)
    end

    private def process_auth(message : Murcure::Messages::Base)
      proto = message.proto
      return unless proto.is_a?(Murcure::Protos::Authenticate)
      
      @clients_storage.update_attr(message.session_id, :username, proto.username)
      @clients_storage.update_attr(message.session_id, :password, proto.password)
      @clients_storage.update_attr(message.session_id, :tokens, proto.tokens)
    end
  end
end
