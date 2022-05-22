require "../utils/stack"
require "../utils/protos"
require "../utils/proto_mapper"

module Murcure
  module Client
    class SocketReader
      class ConnectionClosed < Exception; end

      getter messages : Channel(Protobuf::Message)

      def initialize(@ssl_socket : OpenSSL::SSL::Socket::Server)
        @state_lock = RWLock.new
        @closed = false

        @messages = Channel(Protobuf::Message).new
        @done = Channel(Nil).new
      end

      def receive : Protobuf::Message?
        Channel.receive_first(@messages, @done)
      end

      def start
        spawn do
          until closed?
            begin
              @messages.send(read)
            rescue ConnectionClosed
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
        @done.send(nil)
        @state_lock.write { @closed = true }
      end

      private def read : Protobuf::Message
        stack = receive_stack
        
        proto = ProtoMapper.find_class(stack[:type])      
        memory = IO::Memory.new(stack[:payload])
        proto.from_protobuf(memory)
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

        raise ConnectionClosed.new if size.zero?

        bytes
      end
    end
  end
end
