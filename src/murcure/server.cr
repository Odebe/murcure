module Murcure
  class Server
    @context : OpenSSL::SSL::Context::Server

    def initialize(port : Int32)
      @server = TCPServer.new("localhost", port)
      @context = setup_context
      @server_channel = Channel(Murcure::Message).new # messages from clients to server/other clients
      @clients = [] of NamedTuple(uuid: UUID, client: Murcure::Client, handler: Murcure::ClientHandler, room: Int16)
      @rooms = [] of NamedTuple(id: Int32, users: Array(UUID))
      @message_handler = Murcure::MessageHandler.new(@rooms, @clients)
    end

    def run!
      setup_rooms
      start_new_clients_handling

      loop do
        message = @server_channel.receive
        # puts "\nreceived from #{message.uuid} in main channel:\n#{message.inspect}\n"
        spawn @message_handler.call(message)
      end
    end

    # TODO: get from db
    private def setup_rooms
      @rooms << { id: 0, users: [] of UUID }
    end

    private def start_new_clients_handling
      spawn do
        loop do
          if client_socket = @server.accept?
            uuid = UUID.random
            client = Murcure::Client.new(uuid, client_socket, @context)
            handler = Murcure::ClientHandler.new(client, @server_channel)
            
            @clients << { uuid: uuid, client: client, handler: handler, room: 0_i16 }
            root_room = @rooms.find { |r| r[:id] == 0 }
            if root_room
              root_room[:users] << uuid
            end

            spawn handler.call
          end
        end 
      end
    end

    private def setup_context : OpenSSL::SSL::Context::Server
      context = OpenSSL::SSL::Context::Server.new
      context.private_key = "key.pem"
      context.certificate_chain = "certificate.pem"
      context
    end
  end
end
