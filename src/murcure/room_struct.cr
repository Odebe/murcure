module Murcure
  struct RoomStruct
    getter id : UInt32
    getter parent_id : UInt32
    getter name : String
    getter clients : Array(UInt32)

    def initialize(@id, @parent_id, @name, @clients)
    end
  end
end