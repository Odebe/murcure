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
      puts "version: #{version.inspect}"

      auth_message = handle_auth(receive)

      # send_to_client crypto_setup_message
      # send_to_client channel_states_message
      # send_to_client user_states_message
      # send_to_client server_sync_message

      # loop do
      #   message = receive
      #   # TODO: process messages
      # end
    end

    private def receive
      @message_handler.receive
    end

    private def handle_auth(message)

    end

    private def handle_version(message)
      message
      # { 
      #   version: message.version,
      #   release: message.release,
      #   os: message.os,
      #   os_ver: message.os_version,
      # } 
    end
  end
end
