require "./storage/clients.cr"
require "./storage/rooms.cr"

module Murcure
  class ServerState
    getter welcome_text : String

    def initialize
      @clients = Storage::Clients.new
      @rooms = Storage::Rooms.new
      @rooms.setup!
      @start_room = 0_u32
      @welcome_text = "Welcome to VoIP hotel"
    end

    def default_channel_id
      @rooms.default.channel_id
    end

    def register_client(handler : ClientHandler, machine : ClientState) : Void
      @clients.add_client(handler.session_id, handler, machine)
      @rooms.add_client(@start_room, handler.session_id)
    end

    def users_list
    
    end

    def channels_state : Array(Murcure::RoomStruct)
      rooms = @rooms.read { |storage| storage.rooms.values }
      rooms.map do |room|
        packet = Murcure::Protos::ChannelState.new
        packet.channel_id = room.id.to_u32
        packet.parent = room.parent_id.to_u32
        packet.name = room.name.to_s
        packet
      end
    end
  end
end
