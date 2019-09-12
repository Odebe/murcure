module Murcure
  module ProtosHandler
    extend self

    MESSAGE_CLASSES = {
      0 => Murcure::Protos::Version,
      2 => Murcure::Protos::Authenticate,
      3 => Murcure::Protos::Ping,
    }

    MESSAGE_TYPES = {
      0 => :version,
      2 => :auth,
      3 => :ping,
    }

    def find_struct(type)
      MESSAGE_CLASSES[type]
    end

    def find_type(type)
      MESSAGE_TYPES[type]
    end
  end
end
