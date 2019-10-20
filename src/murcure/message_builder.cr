module Murcure
  # TODO: use as module
  class MessageBuilder
    # contract_of "proto2" do
    #   optional :channel_id, :uint32, 1
    #   optional :parent, :uint32, 2
    #   optional :name, :string, 3
    #   repeated :links, :uint32, 4
    #   optional :description, :string, 5
    #   repeated :links_add, :uint32, 6
    #   repeated :links_remove, :uint32, 7
    #   optional :temporary, :bool, 8, default: false
    #   optional :position, :int32, 9, default: 0
    #   optional :description_hash, :bytes, 10
    #   optional :max_users, :uint32, 11
    # end
    def process_channel_state_message(room : Murcure::RoomStruct)
      m = Murcure::Protos::ChannelState.new
      m.channel_id = room.id.to_u32
      m.parent = room.parent_id.to_u32
      m.name = room.name.to_s
      m
    end

    # contract_of "proto2" do
    #   optional :session, :uint32, 1
    #   optional :actor, :uint32, 2
    #   optional :name, :string, 3
    #   optional :user_id, :uint32, 4
    #   optional :channel_id, :uint32, 5
    #   optional :mute, :bool, 6
    #   optional :deaf, :bool, 7
    #   optional :suppress, :bool, 8
    #   optional :self_mute, :bool, 9
    #   optional :self_deaf, :bool, 10
    #   optional :texture, :bytes, 11
    #   optional :plugin_context, :bytes, 12
    #   optional :plugin_identity, :string, 13
    #   optional :comment, :string, 14
    #   optional :hash, :string, 15
    #   optional :comment_hash, :bytes, 16
    #   optional :texture_hash, :bytes, 17
    #   optional :priority_speaker, :bool, 18
    #   optional :recording, :bool, 19
    # end
    # TODO: struct to users
    def process_user_state_message(user : NamedTuple(session_id: UInt32, handler: Murcure::ClientHandler, machine: Murcure::ClientState, attrs: Hash(Symbol, (String | Int32 | UInt32| Symbol | Nil | Array(String)))))
      m = Murcure::Protos::UserState.new
      m.session = user[:session_id].to_u32
      m.name = user[:attrs][:username].to_s
      m.channel_id = 0_u32
      m
    end

    # contract_of "proto2" do
    #   optional :session, :uint32, 1
    #   optional :max_bandwidth, :uint32, 2
    #   optional :welcome_text, :string, 3
    #   optional :permissions, :uint64, 4
    # end
    def process_server_sync_message(user)
      m = Murcure::Protos::ServerSync.new
      m.session = user[:session_id].to_u32
      m.welcome_text = "Welcome to VoIP страну"
      m
    end

    def process_ping_message
      m = Murcure::Protos::Ping.new
      m.timestamp = 123123
      m
    end
  end
end
