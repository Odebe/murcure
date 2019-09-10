module Murcure
  class Server
    def initialize(port : Int32)
      @server = TCPServer.new(port)
      @client_handlers = [] of Murcure::ClientHandler
      @server_channel = Channel(Murcure::Message).new # messages from clients to server/other clients
    end

    def run!
      loop do
        handle_clients_messages
        if client_socket = @server.accept?
          handle_client_connection(client_socket)
        end
      end
    end

    private def handle_clients_messages
      # TODO: handle messages from clients
    end

    private def handle_client_connection(socket)
      handler = Murcure::ClientHandler.new(@server_channel, Channel(Murcure::Message).new, client_socket)
      @client_handlers << handler
      
      spawn handler.call
    end
  end
end
