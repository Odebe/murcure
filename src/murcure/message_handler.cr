module Murcure
  class MessageHandler
    
    @rooms : Array(NamedTuple(id: Int32, users: Array(UUID)))
    @clients : Array(NamedTuple(uuid: UUID, client: Murcure::Client, handler: Murcure::ClientHandler, room: Int16))
    
    def initialize(@rooms, @clients); end

    def call(message : Murcure::Message)
      sender = @clients.find { |c| c[:uuid] == message.uuid }
      return if sender.nil?

      puts "rooms: #{@rooms.inspect}"
      puts "clients: #{@clients.inspect}"
      
      case message.type
      when :ping
        process_ping(message, sender)
      when :version
        process_version(message, sender)
      when :auth
        process_auth(message, sender)
      else
        nil
        # raise "not defined message"
      end
    end

    private def process_version(message, sender)
      sender[:client].save_version!(message)
      puts sender[:client].version.inspect
    end

    private def process_auth(message : Murcure::Message, sender)
      sender[:client].save_credits!(message)
      puts sender[:client].credits.inspect
    end

    private def process_ping(message : Murcure::Message, sender)
      sender[:handler].client_channel.send(message)
    end
  end
end
