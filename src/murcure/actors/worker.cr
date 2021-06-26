require "../server/state"
require "../client/entity"

module Murcure
  module Actors
    class Worker
      include Earl::Agent
      include Earl::Mailbox(Murcure::Client::Entity)

      def initialize(@server : Server::State)
      end

      def call
        loop do
          client = receive
          puts "new client"
          @server.add_client(client)
          Actors::Client.new(@server, client).start
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
