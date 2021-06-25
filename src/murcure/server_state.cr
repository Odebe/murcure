# require "./storage/clients.cr"
# require "./storage/rooms.cr"

module Murcure
  class ServerState
    getter welcome_text : String

    def initialize
      @welcome_text = "Welcome to VoIP hotel"
      
      @clients_rwlock = RWLock.new
      @clients = [] of Client

      @rooms_rwlock = RWLock.new
      @rooms = [] of Room
      @rooms << Room.new(0_u32, 0_u32, "root", [] of Client)
      @default_room_id = 0_u32
    end

    def users
      @clients_rwlock.read { yield @clients }
    end

    def default_channel_id
      @default_room_id
    end

    def add_to_room(client : Client, room_id : UInt32)
      find_room(room_id).add_client(client)
    end

    def remove_from_room(client : Client, room_id : Nil); end
    def remove_from_room(client : Client, room_id : UInt32)
      find_room(room_id).remove_client(client)
    end

    def add_client(client : Client) : Void
      @clients_rwlock.write { @clients << client }
    end

    def remove_client(client : Client) : Void
      @clients_rwlock.write { @clients.delete client }
      remove_from_room(client, client.channel_id)
    end

    def users_state : Array(Murcure::Protos::UserState)
      @clients.map do |user|
        m = Murcure::Protos::UserState.new
        m.session = user.session_id
        m.name = user.username
        m.channel_id = user.channel_id
        m
      end
    end

    def channels_state : Array(Murcure::Protos::ChannelState)
      @rooms.map do |room|
        m = Murcure::Protos::ChannelState.new
        m.channel_id = room.id.to_u32
        m.parent = room.parent_id.to_u32
        m.name = room.name.to_s
        m
      end
    end

    private def find_room(id : UInt32) : Room
      @rooms_rwlock.read do 
        @rooms.find { |r| r.id == id }
      end.not_nil!
    end
  end
end
