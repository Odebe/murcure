module Murcure
  struct RoomStruct
    getter id : UInt32
    getter parent_id : UInt32
    getter name : String
    getter clients : Array(UUID)

    def initialize(@id, @parent_id, @name, @clients)
    end
  end
end