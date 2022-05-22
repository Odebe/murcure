require "../utils/stack"
require "../utils/protos"
require "../utils/proto_mapper"

module Murcure
  module Client
    class SocketWriter
      class ConnectionClosed < Exception; end

      def initialize(@ssl_socket : OpenSSL::SSL::Socket::Server)
        @state_lock = RWLock.new
        @closed = false

        @messages = Channel(Protobuf::Message).new
      end

      def send(message : Protobuf::Message)
        @messages.send(message)
      end

      def start
        spawn do
          until closed?
            begin
              msg = @messages.receive
              bytes = proto_to_bytes(msg)
              type_num = ProtoMapper.find_type(msg.class)
              puts ">> type: #{type_num}, bytes: #{bytes}"
              send_bytes(type_num, bytes)
            rescue Channel::ClosedError
              close!
              break
            rescue e
              # TODO: write to log file
              puts e.inspect
              puts e.backtrace.join("\n")
              close!
              break
            end
          end
        end
      end

      def closed?
        @state_lock.read { @closed }
      end

      def close!
        @state_lock.write { @closed = true }
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
    end
  end
end
