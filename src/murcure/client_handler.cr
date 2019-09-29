module Murcure
  class ClientHandler
    # data from server/other clien
    # @server_channel : Channel(Murcure::Message)
    # data to server/other_client
    # @client_channel : Channel(Murcure::Message)

    # @message_handler : Murcure::MessageHandler
    getter client_channel : Channel(Murcure::Message)

    def initialize(client : Murcure::Client, server_channel : Channel(Murcure::Message))
      @client = client
      @server_channel = server_channel
      @client_channel = Channel(Murcure::Message).new
      # @message_handler = Murcure::MessageHandler.new(client)
    end

    def call
      spawn handle_messages_from_client
      spawn handle_messages_from_server
    end

    def handle_messages_from_server
      loop do
        message = @client_channel.receive
        puts "\nreceived from main channel in #{message.uuid}:\n#{message.inspect}\n"
        if message.type == :ping
          send_to_client :ping, ping_message(message)
          next
        end

      end
    end

    def handle_messages_from_client
      # version = handle_version(@message_handler.receive) 
      # auth_message = handle_auth(@message_handler.receive)

      loop do
        message = @client.receive   
        puts "received from client socket: #{message.inspect}"
        @server_channel.send(message)
      end
    end

    ## MESSAGES

    def ping_message(message : Murcure::Message) : Hash
      { "timestamp" => 9978166 }
    end

    ## SEND

    private def send_to_client(type : Symbol, message : Hash)
      # @message_handler.send(type, message)
      @client.send(type, message)
    end

    ## HANDLE

    private def handle_auth(message)
      message # TODO
    end

    private def handle_version(message)
      message # TODO
    end
  end
end
