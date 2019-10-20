
module Murcure
  module Messages
    class Input < Base
      getter msg_type : Symbol 
      getter proto : Protobuf::Message
      getter session_id : UInt32

      def initialize(@msg_type, @proto, @session_id); end

      def type
        @msg_type
      end
    end
  end
end
