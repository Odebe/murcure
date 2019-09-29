module Murcure
  class MessageHandler

    def initialize(@clients : Array(NamedTuple(uuid: UUID, client: Murcure::Client, handler: Murcure::ClientHandler, room: Int16))); end

    def call(message : Murcure::Message)
      sender = @clients.find { |c| c[:uuid] == message.uuid }
      return if sender.nil?
      
      case message.type
      when :ping
        process_ping(message, sender)
      else
        nil
        # raise "not defined message"
      end
    end

    private def process_ping(message : Murcure::Message, sender)
      sender[:handler].client_channel.send(message)
    end
  end
end
