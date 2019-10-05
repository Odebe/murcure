module Murcure
  struct Message
    getter type : Symbol
    getter subtype : Symbol
    getter uuid : UUID | Nil
    getter proto_struct : (Protobuf::Message | Nil)
    getter data : (Murcure::RoomStruct | Nil) # Murcure::ClientStruct 

    def initialize(@type, @subtype, @proto_struct, @data, @uuid)
    end
  end
end
