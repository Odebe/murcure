module Murcure
  class Server
    @context : OpenSSL::SSL::Context::Server
    @rooms : Murcure::RoomStorage

    def initialize(port : Int32)
      @server = TCPServer.new("localhost", port)
      @context = setup_context
      @server_channel = Channel(Murcure::Messages::Base).new # messages from clients to server/other clients
      
      @clients = Murcure::ClientStorage.new
      @rooms = setup_rooms
      

      @handler_channel = Channel(Murcure::Messages::Base).new
      spawn Murcure::MessageHandler.new(@clients, @rooms, @handler_channel).call
      # @message_handler = Murcure::MessageHandler.new(@clients, @rooms, Channel(Murcure::Messages::Base).new)
    end

    def run!
      setup_rooms
      start_new_clients_handling

      loop do
        message = @server_channel.receive
        @handler_channel.send(message)
      end
    end

    private def setup_rooms
      rooms = Murcure::RoomStorage.new
      rooms.setup!
      rooms
    end

    private def start_new_clients_handling
      spawn do
        loop do
          if client_socket = @server.accept?
            # uuid = UUID.random
            session_id = Random.new.rand(UInt32::MIN..UInt32::MAX)
            client = Murcure::ClientSocket.new(session_id, client_socket, @context)
            handler = Murcure::ClientHandler.new(client, @server_channel)
            machine = Murcure::ClientState.new.tap(&.act_as_state_machine)

            @clients.add_client(session_id, handler, machine)
            # @clients.update_attr(uuid, :room_id, 0_u32)
            @rooms.add_client(0_u32, session_id)

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
