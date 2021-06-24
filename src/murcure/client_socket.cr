module Murcure
  class ClientSocket
    def initialize(@ssl_socket : OpenSSL::SSL::Socket::Server, @to_server_ch : Channel(Protobuf::Message))
      @from_server_ch = Channel(Protobuf::Message).new
      @state_muxtex = Mutex.new
      @closed = false
      
      # receive
      spawn do
        until closed?
          begin
            @to_server_ch.send(receive_proto)
          rescue e
            puts e.inspect
            close!
          end
        end
      end

      # send
      spawn do
        until closed
          begin
            msg = @from_server_ch.receive
            msg_bytes = convert_proto_tp_bytes(msg)
            send_bytes(msg.type, msg_bytes)
          rescue e
            puts e.inspect
            close!
          end
        end
      end
    end

    def send(message : Protobuf::Message)
      @from_server_ch.send(message)
    end

    def receive : Protobuf::Message
      @to_server_ch.receive
    end

    def closed?
      @state_muxtex.synchronize { @closed } || ssl_socket.closed?
    end

    def close!
      @state_muxtex.synchronize { @closed = true }
      ssl_socket.close
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

    private def receive_proto : Protobuf::Message
      stack = receive_stack
      
      type = Murcure::ProtosHandler.find_type(stack[:type])      
      proto = Murcure::ProtosHandler.find_struct(stack[:type])      
      memory = IO::Memory.new(stack[:payload])
      proto.from_protobuf(memory)
      # Murcure::Messages::Input.new(type, message, @session_id)
    end

    # def send(message : Murcure::Messages::Base) : Nil
    #   type_num = Murcure::ProtosHandler.find_type_number(message.type)
    #   msg_bytes = convert_proto_tp_bytes(message)
    #   puts "type: #{type_num}, bytes: #{msg_bytes}"
    #   send_bytes(type_num, msg_bytes)
    #   nil
    # end

    private def convert_proto_tp_bytes(message : Murcure::Messages::Base) : Bytes
      message_memory = message.proto.not_nil!.to_protobuf
      message_memory.rewind
      bytes = Bytes.new(message_memory.bytesize)
      message_memory.read(bytes)
      bytes
    end

    private def send_bytes(type_num : Int, message_bytes : Bytes)
      memory = IO::Memory.new
      type_num.to_u16.to_io(memory, IO::ByteFormat::NetworkEndian)
      memory.rewind
      type_bytes = Bytes.new(2) 
      memory.read(type_bytes)
      @ssl_socket.unbuffered_write(type_bytes)

      memory = IO::Memory.new
      message_bytes.bytesize.to_u32.to_io(memory, IO::ByteFormat::NetworkEndian)
      memory.rewind
      bytesize_bytes = Bytes.new(4) 
      memory.read(bytesize_bytes)
      @ssl_socket.unbuffered_write(bytesize_bytes)

      @ssl_socket.unbuffered_write(message_bytes)
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
