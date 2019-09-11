module Murcure
  class ClientHandler
    # data from server/other clien
    @input_channel : Channel(Murcure::Message)
    # data to server/other_client
    @output_channel : Channel(Murcure::Message)

    @client : Murcure::Client
    @message_handler : Murcure::MessageHandler

    getter output_channel : Channel(Murcure::Message)

    def initialize(input_channel, output_channel, client_socket : TCPSocket, context : OpenSSL::SSL::Socket::Server)
      @input_channel = input_channel
      @output_channel = output_channel

      @client = Murcure::Client.new(client_socket, context)
      @message_handler = Murcure::MessageHandler.new(@client)
    end

    def call
      send_to_client version_message
      
      version = handle_version(receive) 
      puts "version: #{version.inspect}"

      auth_message = handle_auth(receive)

      send_to_client crypto_setup_message
      send_to_client channel_states_message
      send_to_client user_states_message
      send_to_client server_sync_message

      loop do
        message = recieve
        # TODO: process messages
      end
    end

    private def receive
      @message_handler.receive
    end

    private def handle_auth(message)

    end

    private def handle_version(message)
      { 
        version: message.version,
        release: message.release,
        os: message.os,
        os_ver: message.os_version,
      } 
    end
  end
end
