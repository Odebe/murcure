module Murcure
  class Room
    getter id : UInt32
    getter parent_id : UInt32
    getter name : String
    
    @clients : Array(Client)

    def initialize(@id, @parent_id, @name, @clients)
      @lock = RWLock.new
    end

    def clients
      @lock.read { yield @clients }
    end

    def add_client(client : Client) : Void
      @lock.write { @clients << client }
    end

    def remove_client(client : Client) : Void
      @lock.write { @clients.delete(client) }
    end
  end
end
