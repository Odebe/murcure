module Murcure
  module ProtosHandler
    extend self

    MESSAGE_TYPES = {
      0 => Murcure::Protos::Version,
      2 => Murcure::Protos::Authenticate,
      3 => Murcure::Protos::Ping,
    }

    def find_struct(type)
      MESSAGE_TYPES[type]
    end
  end
end
