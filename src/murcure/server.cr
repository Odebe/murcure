module Murcure
  class Server
    def initialize(port : Int32)
      @server = TCPServer.new(port)
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

    private def handle_client_connection(socket)
      handler = Murcure::ClientHandler.new(@server_channel, Channel(Murcure::Message).new, client_socket, @context)
      @client_handlers << handler
      
      spawn handler.call
    end

    private def setup_context
      context = OpenSSL::SSL::Context::Server.new
      context.private_key = "/path/to/private.key"
      context.certificate_chain = "/path/to/public.cert"
      context
    end
  end
end
