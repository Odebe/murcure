module Murcure
  module Actors
    class Worker
      include Earl::Agent
      include Earl::Mailbox(Murcure::Client)

      def initialize(@server : Murcure::ServerState)
      end

      def call
        loop do
          client = receive
          @server.add_client(client)
          Client.new(@server, client).start
        rescue e
          puts e.inspect
          puts e.backtrace.join("\n")
        ensure
          @server.remove_client(client) if client
        end
      end
    end
  end
end
