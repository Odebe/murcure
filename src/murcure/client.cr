module Murcure
  class Client
    @ssl_socket : OpenSSL::SSL::Socket::Server

    def initialize(tcp_socket : TCPSocket, context : OpenSSL::SSL::Context::Server)
      @ssl_socket = OpenSSL::SSL::Socket::Server.new(tcp_socket, context)
    end

    def receive_head: Bytes
      receive(6) 
    end

    def receive_body(bytes : Int32): Bytes
      receive(bytes)
    end

    private def receive(bytes : Int32) : Bytes
      bytes = Bytes.new(bytes)
      # ssl_socket = OpenSSL::SSL::Socket::Server.new(@tcp_socket, @context)
      @ssl_socket.read(bytes)
      puts String.new(bytes)
      bytes
    end
  end
end
