require "./protos"
require "./server_state"
require "./client"
require "./room"
require "./client_socket"
require "./actors/*"
require "./pool"

module Murcure 
  class NewServer
    def initialize(@host : String, @port : UInt32, @ssl_context : OpenSSL::SSL::Context::Server)
      @server = TCPServer.new(@host, @port)
      @state = ServerState.new
      @workers_pool = Pool(Actors::Worker, Client, ServerState).new(capacity: 10, agent_init_state: @state)
      @workers_pool.call
    end

    def start!
      while socket = @server.accept
        handle_new_client(socket)
      end
    end

    def handle_new_client(client_socket : TCPSocket)
      ssl_socket = OpenSSL::SSL::Socket::Server.new(client_socket, @ssl_context)
      client = Client.new(ssl_socket)

      @workers_pool.send(client)
    end
  end
end
