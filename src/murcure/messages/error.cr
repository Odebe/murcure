
module Murcure
  module Messages
    # TODO: роефаторинг
    class Error < Base
      getter type : Symbol
      getter error : Exception 
      getter session_id : UInt32

      def initialize(@type, @error, @session_id); end

      def proto
        nil
      end
    end
  end
end