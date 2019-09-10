module Murcure
  class Client
    @tcp_socket : TCPSocket

    def initialize(tcp_socket)
      @tcp_socket = tcp_socket
    end

    def recieve
      @tcp_socket.recieve
    end
  end
end