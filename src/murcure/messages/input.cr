
module Murcure
  module Messages
    class Input < Base
      getter msg_type : Symbol 
      getter proto : Protobuf::Message
      getter uuid : UUID

      def initialize(@msg_type, @proto, @uuid); end

      def type
        @msg_type
      end
    end
  end
end
