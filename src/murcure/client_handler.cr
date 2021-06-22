module Murcure
  class ClientHandler
    # data from server/other clien
    # @server_channel : Channel(Murcure::Message)
    # data to server/other_client
    # @client_channel : Channel(Murcure::Message)

    getter client_channel : Channel(Murcure::Messages::Base)

    def initialize(@session_id : UInt32, @client : Murcure::ClientSocket, @server_channel : Channel(Murcure::Messages::Base))
      @client_channel = Channel(Murcure::Messages::Base).new
    end

    def call
      spawn handle_messages_from_client
      spawn handle_messages_from_server
      sleep
    end

    def handle_messages_from_server
      loop do
        message = @client_channel.receive
        @client.send(message)
      end
    rescue e : OpenSSL::SSL::Error
      errmssage = Murcure::Messages::Error.new(:user_remove, e, @session_id )
      @server_channel.send(errmssage) 
    end

    def handle_messages_from_client
      loop do
        message = @client.receive   
        @server_channel.send(message)
      end
    rescue e : OpenSSL::SSL::Error 
      errmssage = Murcure::Messages::Error.new(:user_remove, e, @session_id )
      @server_channel.send(errmssage) 
    end
  end
end
