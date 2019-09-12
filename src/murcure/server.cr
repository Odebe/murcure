module Murcure
  class Server
    @context : OpenSSL::SSL::Context::Server

    def initialize(port : Int32)
      @server = TCPServer.new("localhost", port)
      @context = setup_context
      @client_handlers = [] of Murcure::ClientHandler
      @server_channel = Channel(Murcure::Message).new # messages from clients to server/other clients
    end

    def run!
      loop do
        handle_clients_messages
        
        # new connection
        if client_socket = @server.accept?
          handle_client_connection(client_socket)
        end

      end
    end

    private def handle_clients_messages
      # TODO: handle messages from clients
    end

    private def handle_client_connection(client_socket)
      client = Murcure::Client.new(client_socket, @context)
      handler = Murcure::ClientHandler.new(client, @server_channel)
      
      @client_handlers << handler
      
      spawn handler.call
    end

    private def setup_context : OpenSSL::SSL::Context::Server
      context = OpenSSL::SSL::Context::Server.new
      context.private_key = "key.pem"
      context.certificate_chain = "certificate.pem"
      context
    end
  end
end
