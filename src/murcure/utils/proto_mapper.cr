require "./protos"

module Murcure
  module ProtoMapper
    extend self

    MESSAGE_CLASSES = {
      0 => Murcure::Protos::Version,
      1 => Murcure::Protos::UDPTunnel,
      2 => Murcure::Protos::Authenticate,
      3 => Murcure::Protos::Ping,
      4 => Murcure::Protos::Reject,    
      5 => Murcure::Protos::ServerSync,
      7 => Murcure::Protos::ChannelState,
      8 => Murcure::Protos::UserRemove,
      9 => Murcure::Protos::UserState,
      10 => Murcure::Protos::BanList,
      11 => Murcure::Protos::TextMessage,
      12 => Murcure::Protos::PermissionDenied,
      13 => Murcure::Protos::ACL,
      14 => Murcure::Protos::QueryUsers,
      15 => Murcure::Protos::CryptSetup,
      16 => Murcure::Protos::ContextActionModify,
      17 => Murcure::Protos::ContextAction,
      18 => Murcure::Protos::UserList,
      19 => Murcure::Protos::VoiceTarget,
      20 => Murcure::Protos::PermissionQuery,
      21 => Murcure::Protos::CodecVersion,
      22 => Murcure::Protos::UserStats,
      23 => Murcure::Protos::RequestBlob,
      24 => Murcure::Protos::ServerConfig,
      25 => Murcure::Protos::SuggestConfig,
    }

    {% begin %}
      MESSAGE_NUMBERS = {
        {% for num, klass in MESSAGE_CLASSES %}
          {{ klass }} => {{ num }},
        {% end %}
      }
    {% end %}

    def find_class(type_num)
      MESSAGE_CLASSES[type_num].not_nil!
    end

    def find_type(klass)
      MESSAGE_NUMBERS[klass].not_nil!
    end
  end
end
