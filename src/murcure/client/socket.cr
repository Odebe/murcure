require "../utils/stack"
require "../utils/protos"
require "../utils/proto_mapper"

module Murcure
  module Client
    # This class responsible for encapsulate usage of sockets.
    class Socket
      class ConnectionClosed < Exception; end

      getter done : Channel(Nil)

      def initialize(@ssl_socket : OpenSSL::SSL::Socket::Server)
        @done = Channel(Nil).new

        @reader = SocketReader.new(@ssl_socket)
        @writer = SocketWriter.new(@ssl_socket)

        start!
      end

      def open?
        !@reader.closed? || !@writer.closed?
      end

      def send(message : Protobuf::Message)
        @writer.send(message)
      end

      def receive : Protobuf::Message?
        @reader.receive
      end

      private def start!
        @reader.start
        @writer.start
      end
    end
  end
end
