module Murcure
  class RoomStorage
    getter rooms : Hash(UInt32, Murcure::RoomStruct)

    def initialize
      @rooms = {} of UInt32 => Murcure::RoomStruct      
    end

    # TODO: get rooms from sqlite
    def setup! : Bool
      @rooms[0_u32] = Murcure::RoomStruct.new(0_u32, 0_u32, "Root", [] of UInt32)
      true
    end

    def add_client(room_id : UInt32, client_uuid : UInt32) : Bool
      @rooms[room_id].clients << client_uuid
      true
    end

    def clients(room_id : UInt32) : Array(UInt32)
      @rooms[room_id].clients
    end
  end
end