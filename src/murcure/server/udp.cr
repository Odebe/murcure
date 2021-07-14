require "./state"
require "../utils/ping"

module Murcure 
  module Server
    # This class represents UDP part of server. Creates UDP socket and listens to pings.
    class Udp
      def initialize(@host : String, @port : UInt32, @ssl_context : OpenSSL::SSL::Context::Server, @state : State = State.new)
        @udp = UDPSocket.new
        @udp.bind @host, @port
      end

      def start!
        buffer = Bytes.new(12)
        io = IO::Memory.new

        loop do
          bytes_read, addr = @udp.receive(buffer)
          tmp_io = IO::Memory.new(buffer)
          request = tmp_io.read_bytes(Ping::Request, format: IO::ByteFormat::NetworkEndian)

          response = Ping::Response.new
          response.ident = request.ident
          response.user_count = @state.user_count.to_u32
          response.max_users = @state.max_users.to_u32
          response.bandwidth = @state.max_bandwidth

          response.write(io)
          @udp.send(io.to_s, to: addr)
          io.clear
        end
      end
    end
  end
end
