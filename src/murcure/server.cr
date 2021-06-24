require "./server_state"

module Murcure 
  class NewServer
    def initialize(@host : String, @port : UInt32, @ssl_context : OpenSSL::SSL::Context::Server)
      @server = TCPServer.new(@host, @port)
      @state = ServerState.new
      @workers_pool = Earl::PoolWithState(Actors::Worker, Client, ServerState).new(capacity: 10, state: @state)
    end

    def start!
      while socket = @server.accept?
        handle_new_client(socket)
      end
    end

    def handle_new_client(client_socket : OpenSSL::SSL::Socket::Server)
      socket_reader = ClientSocket.new(client_socket)
      client = Client.new(socket_reader)

      @workers_pool.send(client)
    end
  end
end
