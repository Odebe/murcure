module Murcure
  class ClientHandler
    # data from server/other clien
    # @server_channel : Channel(Murcure::Message)
    # data to server/other_client
    # @client_channel : Channel(Murcure::Message)

    getter client_channel : Channel(Murcure::Messages::Base)

    def initialize(@client : Murcure::ClientSocket, @server_channel : Channel(Murcure::Messages::Base))
      @client_channel = Channel(Murcure::Messages::Base).new
    end

    def call
      spawn handle_messages_from_client
      spawn handle_messages_from_server
    end

    def handle_messages_from_server
      loop do
        message = @client_channel.receive
        puts "handle_messages_from_server: #{message.inspect}"
        @client.send(message)
      end
    end

    def handle_messages_from_client
      loop do
        message = @client.receive
        # puts "handle_messages_from_client: #{message.inspect}" 
        @server_channel.send(message)
      end
    end
  end
end
