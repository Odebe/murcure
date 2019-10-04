module Murcure
  class RoomStorage
    def initialize
      @rooms = {} of UInt32 => NamedTuple(parent_id: UInt32, name: String, clients: Array(UUID))
    end

    # TODO: get rooms from sqlite
    def setup! : Bool
      @rooms[0_u32] = { parent_id: 0_u32, name: "Root", clients: [] of UUID }
      true
    end

    def add_client(room_id : UInt32, client_uuid : UUID) : Bool
      @rooms[room_id][:clients] << client_uuid
      true
    end

    def clients(room_id : UInt32) : Array(UUID)
      @rooms[room_id][:clients]
    end
  end
end