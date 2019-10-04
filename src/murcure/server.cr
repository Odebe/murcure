module Murcure
  class Server
    @context : OpenSSL::SSL::Context::Server

    def initialize(port : Int32)
      @server = TCPServer.new("localhost", port)
      @context = setup_context
      @server_channel = Channel(Murcure::Message).new # messages from clients to server/other clients
      @clients = Murcure::ClientStorage.new
      @message_handler = Murcure::MessageHandler.new(@clients)
    end

    def run!
      setup_rooms
      start_new_clients_handling

      loop do
        message = @server_channel.receive
        # puts "\nreceived from #{message.uuid} in main channel:\n#{message.inspect}\n"
        spawn @message_handler.call(message)
      end
    end

    private def start_new_clients_handling
      spawn do
        loop do
          if client_socket = @server.accept?
            uuid = UUID.random
            client = Murcure::ClientSocket.new(uuid, client_socket, @context)
            handler = Murcure::ClientHandler.new(client, @server_channel)
            @clients.add_client(uuid, handler)
            @clients.update_attr(uuid, :room_id, 0_i32)
            spawn handler.call
          end
        end 
      end
    end

    private def setup_context : OpenSSL::SSL::Context::Server
      context = OpenSSL::SSL::Context::Server.new
      context.private_key = "key.pem"
      context.certificate_chain = "certificate.pem"
      context
    end
  end
end
