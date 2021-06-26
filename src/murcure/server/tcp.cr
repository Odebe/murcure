require "./state"
require "../actors/*"

require "../utils/pool"

module Murcure 
  module Server
    class Tcp
      def initialize(@host : String, @port : UInt32, @ssl_context : OpenSSL::SSL::Context::Server, @state : State = State.new)
        @server = TCPServer.new(@host, @port)
        @workers_pool = Pool(Actors::Worker, Client::Entity, Server::State).new(capacity: 10, agent_init_state: @state)
        @workers_pool.call
      end

      def start!
        loop do
          socket = @server.accept
          break if socket.nil?

          handle_new_client(socket)
        rescue e : OpenSSL::SSL::Error
          # probably new user that accepted cert so don't panic
          next
        end
      end

      def handle_new_client(client_socket : TCPSocket)
        ssl_socket = OpenSSL::SSL::Socket::Server.new(client_socket, @ssl_context)
        client = Client::Entity.new(ssl_socket)

        @workers_pool.send(client)
      end
    end
  end
end
