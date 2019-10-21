module Murcure
  module ProtosHandler
    extend self

    MESSAGE_CLASSES = {
      0 => Murcure::Protos::Version,
      1 => Murcure::Protos::UDPTunnel,
      2 => Murcure::Protos::Authenticate,
      3 => Murcure::Protos::Ping,
      4 => Murcure::Protos::Reject,    
      5 => Murcure::Protos::ServerSync,
      7 => Murcure::Protos::ChannelState,
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
    }

# 20	PermissionQuery
# 21	CodecVersion
# 22	UserStats
# 23	RequestBlob
# 24	ServerConfig
# 25	SuggestConfig

    MESSAGE_TYPES = {
      0 => :version,
      1 => :udp_tunnel,
      2 => :auth,
      3 => :ping,
      4 => :reject,
      5 => :server_sync,
      6 => :channel_remove,
      7 => :channel_state,
      8 => :user_remove,
      9 => :user_state,
      10 => :ban_list,
      11 => :text_message,
      12 => :perm_denied,
      13 => :alc,
      14 => :query_users,
      15 => :crypto_setup,
      16 => :context_action_modify,
      17 => :context_action,
      18 => :users_list,
      19 => :vouce_target,
      20 => :perm_query,
    }

    def find_struct(type)
      MESSAGE_CLASSES[type]
    end

    def find_type(type) : Symbol
      MESSAGE_TYPES[type]
    end

    def find_type_number(type : Symbol) : Int
      number = MESSAGE_TYPES.find { |k, v| v == type }.not_nil!.first
    end
  end
end
