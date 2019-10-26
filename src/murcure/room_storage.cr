module Murcure
  class RoomStorage
    getter rooms : Hash(UInt32, Murcure::RoomStruct)

    def initialize
      @mutex = Mutex.new
      @rooms = {} of UInt32 => Murcure::RoomStruct      
    end

    # TODO: get rooms from sqlite
    def setup! : Bool
      @rooms[0_u32] = Murcure::RoomStruct.new(0_u32, 0_u32, "root", [] of UInt32)
      true
    end

    def client_rooms(client_session_id : UInt32) : Array(Murcure::RoomStruct)
      @rooms.select { |_room_id, room| room.clients.includes?(client_session_id)  }.values
    end

    def add_client(room_id : UInt32, client_session_id : UInt32) : Bool
      @mutex.synchronize { @rooms[room_id].clients << client_session_id }
      true
    end

    def clients(room_id : UInt32) : Array(UInt32)
      @rooms[room_id].clients
    end
  end
end
