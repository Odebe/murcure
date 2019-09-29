## Generated from Mumble.proto for MumbleProto
require "protobuf"

module Murcure
  module Protos
    
    struct Version
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :version, :uint32, 1
        optional :release, :string, 2
        optional :os, :string, 3
        optional :os_version, :string, 4
      end
    end
    
    struct UDPTunnel
      include Protobuf::Message
      
      contract_of "proto2" do
        required :packet, :bytes, 1
      end
    end
    
    struct Authenticate
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :username, :string, 1
        optional :password, :string, 2
        repeated :tokens, :string, 3
        repeated :celt_versions, :int32, 4
        optional :opus, :bool, 5, default: false
      end
    end
    
    struct Ping
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :timestamp, :uint64, 1
        optional :good, :uint32, 2
        optional :late, :uint32, 3
        optional :lost, :uint32, 4
        optional :resync, :uint32, 5
        optional :udp_packets, :uint32, 6
        optional :tcp_packets, :uint32, 7
        optional :udp_ping_avg, :float, 8
        optional :udp_ping_var, :float, 9
        optional :tcp_ping_avg, :float, 10
        optional :tcp_ping_var, :float, 11
      end
    end
    
    struct Reject
      include Protobuf::Message
      enum RejectType
        None = 0
        WrongVersion = 1
        InvalidUsername = 2
        WrongUserPW = 3
        WrongServerPW = 4
        UsernameInUse = 5
        ServerFull = 6
        NoCertificate = 7
        AuthenticatorFail = 8
      end
      
      contract_of "proto2" do
        optional :type, Reject::RejectType, 1
        optional :reason, :string, 2
      end
    end
    
    struct ServerSync
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :session, :uint32, 1
        optional :max_bandwidth, :uint32, 2
        optional :welcome_text, :string, 3
        optional :permissions, :uint64, 4
      end
    end
    
    struct ChannelRemove
      include Protobuf::Message
      
      contract_of "proto2" do
        required :channel_id, :uint32, 1
      end
    end
    
    struct ChannelState
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :channel_id, :uint32, 1
        optional :parent, :uint32, 2
        optional :name, :string, 3
        repeated :links, :uint32, 4
        optional :description, :string, 5
        repeated :links_add, :uint32, 6
        repeated :links_remove, :uint32, 7
        optional :temporary, :bool, 8, default: false
        optional :position, :int32, 9, default: 0
        optional :description_hash, :bytes, 10
        optional :max_users, :uint32, 11
      end
    end
    
    struct UserRemove
      include Protobuf::Message
      
      contract_of "proto2" do
        required :session, :uint32, 1
        optional :actor, :uint32, 2
        optional :reason, :string, 3
        optional :ban, :bool, 4
      end
    end
    
    struct UserState
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :session, :uint32, 1
        optional :actor, :uint32, 2
        optional :name, :string, 3
        optional :user_id, :uint32, 4
        optional :channel_id, :uint32, 5
        optional :mute, :bool, 6
        optional :deaf, :bool, 7
        optional :suppress, :bool, 8
        optional :self_mute, :bool, 9
        optional :self_deaf, :bool, 10
        optional :texture, :bytes, 11
        optional :plugin_context, :bytes, 12
        optional :plugin_identity, :string, 13
        optional :comment, :string, 14
        optional :hash, :string, 15
        optional :comment_hash, :bytes, 16
        optional :texture_hash, :bytes, 17
        optional :priority_speaker, :bool, 18
        optional :recording, :bool, 19
      end
    end
    
    struct BanList
      include Protobuf::Message
      
      struct BanEntry
        include Protobuf::Message
        
        contract_of "proto2" do
          required :address, :bytes, 1
          required :mask, :uint32, 2
          optional :name, :string, 3
          optional :hash, :string, 4
          optional :reason, :string, 5
          optional :start, :string, 6
          optional :duration, :uint32, 7
        end
      end
      
      contract_of "proto2" do
        repeated :bans, BanList::BanEntry, 1
        optional :query, :bool, 2, default: false
      end
    end
    
    struct TextMessage
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :actor, :uint32, 1
        repeated :session, :uint32, 2
        repeated :channel_id, :uint32, 3
        repeated :tree_id, :uint32, 4
        required :message, :string, 5
      end
    end
    
    struct PermissionDenied
      include Protobuf::Message
      enum DenyType
        Text = 0
        Permission = 1
        SuperUser = 2
        ChannelName = 3
        TextTooLong = 4
        H9K = 5
        TemporaryChannel = 6
        MissingCertificate = 7
        UserName = 8
        ChannelFull = 9
        NestingLimit = 10
        ChannelCountLimit = 11
      end
      
      contract_of "proto2" do
        optional :permission, :uint32, 1
        optional :channel_id, :uint32, 2
        optional :session, :uint32, 3
        optional :reason, :string, 4
        optional :type, PermissionDenied::DenyType, 5
        optional :name, :string, 6
      end
    end
    
    struct ACL
      include Protobuf::Message
      
      struct ChanGroup
        include Protobuf::Message
        
        contract_of "proto2" do
          required :name, :string, 1
          optional :inherited, :bool, 2, default: true
          optional :inherit, :bool, 3, default: true
          optional :inheritable, :bool, 4, default: true
          repeated :add, :uint32, 5
          repeated :remove, :uint32, 6
          repeated :inherited_members, :uint32, 7
        end
      end
      
      struct ChanACL
        include Protobuf::Message
        
        contract_of "proto2" do
          optional :apply_here, :bool, 1, default: true
          optional :apply_subs, :bool, 2, default: true
          optional :inherited, :bool, 3, default: true
          optional :user_id, :uint32, 4
          optional :group, :string, 5
          optional :grant, :uint32, 6
          optional :deny, :uint32, 7
        end
      end
      
      contract_of "proto2" do
        required :channel_id, :uint32, 1
        optional :inherit_acls, :bool, 2, default: true
        repeated :groups, ACL::ChanGroup, 3
        repeated :acls, ACL::ChanACL, 4
        optional :query, :bool, 5, default: false
      end
    end
    
    struct QueryUsers
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :ids, :uint32, 1
        repeated :names, :string, 2
      end
    end
    
    struct CryptSetup
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :key, :bytes, 1
        optional :client_nonce, :bytes, 2
        optional :server_nonce, :bytes, 3
      end
    end
    
    struct ContextActionModify
      include Protobuf::Message
      enum Context
        Server = 1
        Channel = 2
        User = 4
      end
      enum Operation
        Add = 0
        Remove = 1
      end
      
      contract_of "proto2" do
        required :action, :string, 1
        optional :text, :string, 2
        optional :context, :uint32, 3
        optional :operation, ContextActionModify::Operation, 4
      end
    end
    
    struct ContextAction
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :session, :uint32, 1
        optional :channel_id, :uint32, 2
        required :action, :string, 3
      end
    end
    
    struct UserList
      include Protobuf::Message
      
      struct User
        include Protobuf::Message
        
        contract_of "proto2" do
          required :user_id, :uint32, 1
          optional :name, :string, 2
          optional :last_seen, :string, 3
          optional :last_channel, :uint32, 4
        end
      end
      
      contract_of "proto2" do
        repeated :users, UserList::User, 1
      end
    end
    
    struct VoiceTarget
      include Protobuf::Message
      
      struct Target
        include Protobuf::Message
        
        contract_of "proto2" do
          repeated :session, :uint32, 1
          optional :channel_id, :uint32, 2
          optional :group, :string, 3
          optional :links, :bool, 4, default: false
          optional :children, :bool, 5, default: false
        end
      end
      
      contract_of "proto2" do
        optional :id, :uint32, 1
        repeated :targets, VoiceTarget::Target, 2
      end
    end
    
    struct PermissionQuery
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :channel_id, :uint32, 1
        optional :permissions, :uint32, 2
        optional :flush, :bool, 3, default: false
      end
    end
    
    struct CodecVersion
      include Protobuf::Message
      
      contract_of "proto2" do
        required :alpha, :int32, 1
        required :beta, :int32, 2
        required :prefer_alpha, :bool, 3, default: true
        optional :opus, :bool, 4, default: false
      end
    end
    
    struct UserStats
      include Protobuf::Message
      
      struct Stats
        include Protobuf::Message
        
        contract_of "proto2" do
          optional :good, :uint32, 1
          optional :late, :uint32, 2
          optional :lost, :uint32, 3
          optional :resync, :uint32, 4
        end
      end
      
      contract_of "proto2" do
        optional :session, :uint32, 1
        optional :stats_only, :bool, 2, default: false
        repeated :certificates, :bytes, 3
        optional :from_client, UserStats::Stats, 4
        optional :from_server, UserStats::Stats, 5
        optional :udp_packets, :uint32, 6
        optional :tcp_packets, :uint32, 7
        optional :udp_ping_avg, :float, 8
        optional :udp_ping_var, :float, 9
        optional :tcp_ping_avg, :float, 10
        optional :tcp_ping_var, :float, 11
        optional :version, Version, 12
        repeated :celt_versions, :int32, 13
        optional :address, :bytes, 14
        optional :bandwidth, :uint32, 15
        optional :onlinesecs, :uint32, 16
        optional :idlesecs, :uint32, 17
        optional :strong_certificate, :bool, 18, default: false
        optional :opus, :bool, 19, default: false
      end
    end
    
    struct RequestBlob
      include Protobuf::Message
      
      contract_of "proto2" do
        repeated :session_texture, :uint32, 1
        repeated :session_comment, :uint32, 2
        repeated :channel_description, :uint32, 3
      end
    end
    
    struct ServerConfig
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :max_bandwidth, :uint32, 1
        optional :welcome_text, :string, 2
        optional :allow_html, :bool, 3
        optional :message_length, :uint32, 4
        optional :image_message_length, :uint32, 5
        optional :max_users, :uint32, 6
      end
    end
    
    struct SuggestConfig
      include Protobuf::Message
      
      contract_of "proto2" do
        optional :version, :uint32, 1
        optional :positional, :bool, 2
        optional :push_to_talk, :bool, 3
      end
    end
    end
  end
