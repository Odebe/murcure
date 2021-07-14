module Murcure
  module Server
    # This struct holds information from config file.
    struct Config
      include Totem::ConfigBuilder
      
      # Connection
      property host : String
      property port : UInt32

      property enable_udp : Bool

      # Sorta tech stuff
      property max_users : UInt8
      property max_bandwidth : UInt32

      # UX
      property welcome_text : String
      property default_room_id : UInt32

      # Security
      property private_key_path : String
      property cert_path : String

      build do
        config_name "config"
        config_type "yaml"
        config_paths ["/etc/murcure", "./"]
      end
    end
  end
end
