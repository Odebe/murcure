require "../client/entity"

module Murcure
  module Room
    # Stores clients list and provides read\write look to access\modify clients list.
    class Entity
      getter id : UInt32
      getter parent_id : UInt32
      getter name : String
      
      @clients : Array(Client::Entity)

      def initialize(@id, @parent_id, @name, @clients)
        @lock = RWLock.new
      end

      def clients
        @lock.read { yield @clients }
      end

      def add_client(client : Client::Entity) : Void
        @lock.write { @clients << client }
      end

      def remove_client(client : Client::Entity) : Void
        @lock.write { @clients.delete(client) }
      end
    end
  end
end
