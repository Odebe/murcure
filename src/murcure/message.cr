module Murcure
  class Message
    @proto_struct : Protobuf::Message

    getter proto_struct : Protobuf::Message
    getter type : Symbol

    def initialize(proto_struct, type)
      @proto_struct = proto_struct
      @type = type
    end

    def decorator
      case @type
      when :ping
        Murcure::MessageDecorators::PingDecorator.new(@proto_struct)
      else
        raise "decorator not defined"
      end
    end
  end
end
