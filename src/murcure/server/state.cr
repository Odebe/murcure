require "../client/entity"
require "../room/entity"

require "../utils/protos"

module Murcure
  module Server
    # This class is used to store state of server.
    # Instance provide methods to acces users, rooms and information from config.
    class State
      def initialize(@config : Server::Config)
        @clients_rwlock = RWLock.new
        @clients = [] of Client::Entity
        @rooms_rwlock = RWLock.new
        @rooms = [] of Room::Entity
        @rooms << Room::Entity.new(0_u32, 0_u32, "root", [] of Client::Entity)
      end

      def welcome_text
        @config.welcome_text
      end

      def max_users
        @config.max_users
      end

      def max_bandwidth
        @config.max_bandwidth
      end

      def users
        @clients_rwlock.read { yield @clients }
      end
      
      def user_count
        users { |u| u.size }
      end

      def default_channel_id
        @config.default_room_id
      end

      def add_to_room(client : Client::Entity, room_id : UInt32)
        find_room(room_id).add_client(client)
      end

      def remove_from_room(client : Client::Entity, room_id : Nil); end
      def remove_from_room(client : Client::Entity, room_id : UInt32)
        find_room(room_id).remove_client(client)
      end

      def add_client(client : Client::Entity) : Void
        @clients_rwlock.write { @clients << client }
      end

      def select_rooms(ids : Array(UInt32)) : Array(Room::Entity)
        @rooms_rwlock.read do
          @rooms.select { |r| ids.includes? r.id }
        end
      end

      def remove_client(client : Client::Entity) : Void
        remove_from_room(client, client.channel_id)
        @clients_rwlock.write { @clients.delete client }
        
        msg = Murcure::Protos::UserRemove.new(session: client.session_id.not_nil!)
        users { |us| us.each { |u| u.send(msg) } }
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

      private def find_room(id : UInt32) : Room::Entity
        @rooms_rwlock.read do 
          @rooms.find { |r| r.id == id }
        end.not_nil!
      end
    end
  end
end
