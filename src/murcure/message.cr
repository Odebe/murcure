module Murcure
  class Message
    @proto_struct : Protobuf::Message

    getter proto_struct : Protobuf::Message
    getter type : Symbol
    getter uuid : UUID

    def initialize(proto_struct, type, uuid)
      @proto_struct = proto_struct
      @type = type
      @uuid = uuid
    end
  end
end
