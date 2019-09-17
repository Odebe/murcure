module Murcure
  module ProtosHandler
    extend self

    MESSAGE_CLASSES = {
      0 => Murcure::Protos::Version,
      2 => Murcure::Protos::Authenticate,
      3 => Murcure::Protos::Ping,
      9 => Murcure::Protos::UserState,
    }

    MESSAGE_TYPES = {
      0 => :version,
      2 => :auth,
      3 => :ping,
      9 => :user_state,
    }

    def find_struct(type)
      MESSAGE_CLASSES[type]
    end

    def find_type(type) : Symbol
      MESSAGE_TYPES[type]
    end

    def find_type_number(type : Symbol) : Int
      number = MESSAGE_TYPES.find { |k, v| v == type }
      if number.is_a?(Nil)
        raise "can not found type"
      else
        number.first
      end
    end
  end
end
