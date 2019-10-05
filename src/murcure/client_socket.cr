module Murcure
  class ClientSocket
    @ssl_socket : OpenSSL::SSL::Socket::Server
    # @version : Hash(Symbol, (String | UInt32 | Nil))
    # @credits : Hash(Symbol, (String | UInt32 | Nil | Array(String)))

    getter uuid : UUID
    # getter version
    # getter credits

    def initialize(@uuid : UUID, tcp_socket : TCPSocket, context : OpenSSL::SSL::Context::Server)
      @ssl_socket = OpenSSL::SSL::Socket::Server.new(tcp_socket, context)
      # @version = {} of Symbol => (String | UInt32 | Nil)
      # @credits = {} of Symbol => (String | UInt32 | Nil | Array(String))
    end

    # # TODO: move somewhere
    # def save_credits!(message)
    #   proto = message.proto_struct
    #   return unless proto.is_a?(Murcure::Protos::Authenticate)

    #   @credits[:username] = proto.username
    #   @credits[:password] = proto.password
    #   @credits[:tokens] = proto.tokens
    # end

    # # TODO: move somewhere
    # def save_version!(message)
    #   proto = message.proto_struct
    #   return unless proto.is_a?(Murcure::Protos::Version)
      
    #   @version[:version] = proto.version
    #   @version[:release] = proto.release
    #   @version[:os] = proto.os
    #   @version[:os_version] = proto.os_version
    # end

    def receive : Murcure::Message
      stack = receive_stack
      
      proto = Murcure::ProtosHandler.find_struct(stack[:type])
      type = Murcure::ProtosHandler.find_type(stack[:type])
      
      memory = IO::Memory.new(stack[:payload])
      message = proto.from_protobuf(memory)
      
      Murcure::Message.new(:proto, type, message, nil, @uuid)
    end

    def send(type : Symbol, message : Hash)
      type_num = Murcure::ProtosHandler.find_type_number(type)
      proto_resp = Murcure::MessageBuilder.new(type).call(message)
      send_bytes(type_num, proto_resp)
    end

    private def send_bytes(type_num : Int, message_bytes : Bytes)
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

    private def receive_stack
      header_bytes = receive_header
      
      io = IO::Memory.new(header_bytes)
      stack = io.read_bytes(Murcure::Stack, format: IO::ByteFormat::NetworkEndian)
      payload = receive_payload(stack.size)
      
      { :type => stack.type, :size => stack.size, :payload => payload }
    end
    
    private def receive_header : Bytes; receive_bytes(6); end
    private def receive_payload(size : UInt32) : Bytes; receive_bytes(size); end

    private def receive_bytes(size : UInt32) : Bytes
      bytes = Bytes.new(size)
      @ssl_socket.read(bytes)
      bytes
    end
  end
end
