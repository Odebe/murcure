module Murcure
  class ClientHandler
    # data from server/other clien
    @server_channel : Channel(Murcure::Message)
    # data to server/other_client
    @client_channel : Channel(Murcure::Message)

    @message_handler : Murcure::MessageHandler
    getter client_channel : Channel(Murcure::Message)

    def initialize(client : Murcure::Client, server_channel : Channel(Murcure::Message))
      @server_channel = server_channel
      @client_channel = Channel(Murcure::Message).new
      @message_handler = Murcure::MessageHandler.new(client)
    end

    def call
      # send_to_client version_message
      
      version = handle_version(receive) 
      auth_message = handle_auth(receive)

      # send_to_client :crypro, crypto_setup_message
      # send_to_client channel_states_message
      # send_to_client user_states_message
      # send_to_client server_sync_message
      
      loop do        
        message = receive        
        if message.type == :ping
          send_to_client :ping, ping_message(message)
          next
        end

        # TODO: process messages
      end
    end

    ## MESSAGES

    def ping_message(message : Murcure::Message) : Hash
      { "timestamp" => 9978166 }
    end

    ## SEND

    private def send_to_client(type : Symbol, message : Hash)
      @message_handler.send(type, message)
    end

    ## HANDLE

    private def handle_auth(message)
      message # TODO
    end

    private def handle_version(message)
      message # TODO
    end

    private def receive : Murcure::Message
      res = @message_handler.receive
      puts res.inspect
      res
    end
  end
end
