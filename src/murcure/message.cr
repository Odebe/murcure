module Murcure
  struct Message
    getter type : Symbol
    getter subtype : Symbol
    getter session_id : UInt32 | Nil
    getter proto_struct : (Protobuf::Message | Nil)
    getter data : (Murcure::RoomStruct | Nil) # Murcure::ClientStruct 

    def initialize(@type, @subtype, @proto_struct, @data, @session_id)
    end
  end
end
