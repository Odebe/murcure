module Murcure
  class Message
    @struct : Protobuf::Message

    def initialize(proto_struct, type : Symbol)
      @struct = proto_struct
      @type = type
    end
  end
end
