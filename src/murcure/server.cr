module Murcure 
  class NewServer < Earl::SSLServer
    def initialize(*args)
      @clients = Murcure::ClientStorage.new
      @rooms = Murcure::RoomStorage.new
      @rooms.setup!

      @server_channel = Channel(Murcure::Messages::Base).new # messages from clients to server/other clients
      @message_handler = Murcure::MessageHandler.new(@clients, @rooms)
      
      super(*args) do |client_socket|
        puts client_socket.inspect
        
        session_id = Random.rand(UInt32::MIN..UInt32::MAX)
        client = Murcure::ClientSocket.new(session_id, client_socket)
        handler = Murcure::ClientHandler.new(session_id, client, @server_channel)
        machine = Murcure::ClientState.new.tap(&.act_as_state_machine)

        @clients.add_client(session_id, handler, machine)
        @rooms.add_client(0_u32, session_id)

        ::spawn handler.call
      end
    end
  end
end

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
      
      @message_handler = Murcure::MessageHandler.new(@clients, @rooms)
    end

    def run!
      setup_rooms
      start_new_clients_handling

      loop do
        message = @server_channel.receive
        if message.is_a? Murcure::Messages::Error
          spawn @message_handler.handle_error(message)
        else
          spawn @message_handler.handle_message(message)
        end
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
          begin
            if client_socket = @server.accept?
              session_id = Random.rand(UInt32::MIN..UInt32::MAX)
              client = Murcure::ClientSocket.new(session_id, client_socket, @context)
              handler = Murcure::ClientHandler.new(session_id, client, @server_channel)
              machine = Murcure::ClientState.new.tap(&.act_as_state_machine)

              @clients.add_client(session_id, handler, machine)
              @rooms.add_client(0_u32, session_id)

              spawn handler.call
            end
          rescue
            # puts e.inspect
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
