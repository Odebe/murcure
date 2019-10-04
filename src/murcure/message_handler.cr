module Murcure
  class MessageHandler
    
    @clients_storage : Murcure::ClientStorage
    @rooms_storage : Murcure::RoomStorage

    def initialize(@clients_storage, @rooms_storage); end

    def call(message : Murcure::Message)
      sender = @clients_storage.get_client(message.uuid)
      return if sender.nil?

      puts sender[:attrs].inspect
      puts @rooms_storage.inspect
      
      case message.type
      when :ping
        process_ping(message)
      when :version
        process_version(message)
      when :auth
        process_auth(message)
      else
        nil
        # raise "not defined message"
      end
    end

    private def process_version(message : Murcure::Message)
      proto = message.proto_struct
      return unless proto.is_a?(Murcure::Protos::Version)

      client = @clients_storage.get_client(message.uuid)
      return unless client[:machine].state == :need_auth
      
      @clients_storage.update_attr(message.uuid, :version, proto.version)
      @clients_storage.update_attr(message.uuid, :release, proto.release)
      @clients_storage.update_attr(message.uuid, :os, proto.os)
      @clients_storage.update_attr(message.uuid, :os_version, proto.os_version)
    end

    private def process_auth(message : Murcure::Message)
      proto = message.proto_struct
      return unless proto.is_a?(Murcure::Protos::Authenticate)

      client = @clients_storage.get_client(message.uuid)
      return unless client[:machine].state == :need_auth
      
      @clients_storage.update_attr(message.uuid, :username, proto.username)
      @clients_storage.update_attr(message.uuid, :password, proto.password)
      @clients_storage.update_attr(message.uuid, :tokens, proto.tokens)

      client[:machine].fire(:authenticate)
    end

    private def process_ping(message : Murcure::Message)
      @clients_storage.channel(message.uuid).send(message)
    end
  end
end
