module Murcure
  class Client
    @ssl_socket : OpenSSL::SSL::Socket::Server

    def initialize(tcp_socket : TCPSocket, context : OpenSSL::SSL::Context::Server)
      @ssl_socket = OpenSSL::SSL::Socket::Server.new(tcp_socket, context)
    end

    def send_stack(data)
      
    end

    def receive_stack
      header_bytes = receive_header
      
      io = IO::Memory.new(header_bytes)
      stack = io.read_bytes(Murcure::Stack, format: IO::ByteFormat::NetworkEndian)
      payload = receive_payload(stack.size)
      
      { :type => stack.type, :size => stack.size, :payload => payload }
    end
    
    private def receive_header : Bytes; receive(6); end
    private def receive_payload(size : UInt32) : Bytes; receive(size); end

    private def receive(size : UInt32) : Bytes
      bytes = Bytes.new(size)
      @ssl_socket.read(bytes)
      bytes
    end
  end
end
