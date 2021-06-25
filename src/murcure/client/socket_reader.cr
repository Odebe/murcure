require "../utils/stack"
require "../utils/protos"
require "../utils/proto_mapper"

module Murcure
  module Client
    class SocketReader
      class ConnectionClosed < Exception; end

      getter done : Channel(Nil)

      def initialize(@ssl_socket : OpenSSL::SSL::Socket::Server, @to_server_ch : Channel(Protobuf::Message))
        @from_server_ch = Channel(Protobuf::Message).new
        @state_mutex = Mutex.new
        @closed = false
        @last_butes = Bytes.new(0)
        @done = Channel(Nil).new

        # receive
        spawn do
          until closed?
            begin
              @to_server_ch.send(read)
            rescue e : ConnectionClosed
              close!
            rescue e
              puts e.inspect
              puts e.backtrace.join("\n")
              close!
              break
            end
          end
        end

        # send
        spawn do
          until closed?
            begin
              msg = @from_server_ch.receive
              bytes = proto_to_bytes(msg)
              type_num = ProtoMapper.find_type(msg.class)
              puts ">> type: #{type_num}, bytes: #{bytes}"
              send_bytes(type_num, bytes)
            rescue e : Channel::ClosedError
              break
            rescue e
              puts e.inspect
              puts e.backtrace.join("\n")

              close!
              break
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
        @state_mutex.synchronize { @closed } || @ssl_socket.closed? # || @last_butes.empty?
      end

      def close!
        @state_mutex.synchronize { @closed = true }
        @ssl_socket.close rescue nil
        @to_server_ch.close
        @from_server_ch.close
      end

      private def read : Protobuf::Message
        stack = receive_stack
        
        proto = ProtoMapper.find_class(stack[:type])      
        memory = IO::Memory.new(stack[:payload])
        proto.from_protobuf(memory)
      end

      private def proto_to_bytes(message : Protobuf::Message) : Bytes
        message_memory = message.to_protobuf
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

        puts "<< type: #{stack.type}, bytes: #{payload}"
        
        { :type => stack.type, :size => stack.size, :payload => payload }
      end
      
      private def receive_header : Bytes; receive_bytes(6); end
      private def receive_payload(size : UInt32) : Bytes; receive_bytes(size); end

      private def receive_bytes(size : UInt32) : Bytes
        bytes = Bytes.new(size)
        size = @ssl_socket.read(bytes)

        # @last_butes = butes
        raise ConnectionClosed.new if size.zero?

        bytes
      end
    end
  end
end