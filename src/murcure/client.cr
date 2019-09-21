module Murcure
  class Client
    @ssl_socket : OpenSSL::SSL::Socket::Server

    def initialize(tcp_socket : TCPSocket, context : OpenSSL::SSL::Context::Server)
      @ssl_socket = OpenSSL::SSL::Socket::Server.new(tcp_socket, context)
    end

    def send(type_num : Int, message_bytes : Bytes)
      memory = IO::Memory.new
      type_num.to_u16.to_io(memory, IO::ByteFormat::NetworkEndian)
      memory.rewind
      type_bytes = Bytes.new(2) 
      memory.read(type_bytes)
      @ssl_socket.unbuffered_write(type_bytes)
      # puts "type_bytes: #{type_bytes}"

      memory = IO::Memory.new
      message_bytes.bytesize.to_u32.to_io(memory, IO::ByteFormat::NetworkEndian)
      memory.rewind
      bytesize_bytes = Bytes.new(4) 
      memory.read(bytesize_bytes)
      @ssl_socket.unbuffered_write(bytesize_bytes)
      # puts "type_bytes: #{bytesize_bytes}"

      @ssl_socket.unbuffered_write(message_bytes)
      # puts "type_bytes: #{message_bytes}"
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
