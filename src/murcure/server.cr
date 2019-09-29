module Murcure
  class Server
    @context : OpenSSL::SSL::Context::Server

    def initialize(port : Int32)
      @server = TCPServer.new("localhost", port)
      @context = setup_context
      @server_channel = Channel(Murcure::Message).new # messages from clients to server/other clients
      @clients = [] of NamedTuple(uuid: UUID, client: Murcure::Client, handler: Murcure::ClientHandler, room: Int16)
    end

    def run!
      start_new_clients_handling

      loop do
        message = @server_channel.receive
        puts "\nreceived from #{message.uuid} in main channel:\n#{message.inspect}\n"
        handle_message(message)
      end
    end

    private def handle_message(message : Murcure::Message)
      spawn Murcure::MessageHandler.new(@clients).call(message)
      # sender_uuid = message.uuid
      # sender = @clients.find { |c| c[:uuid] == sender_uuid }
      # if sender
      #   # puts "sender: #{sender.inspect}"
      #   Murcure::MessageHandler.new(@clients).call(message)
      #   # puts "\nsending back to #{sender[:uuid]}, message:\n#{message.inspect}\n"
      #   # sender[:handler].client_channel.send(message)
      # else
      #   next
      # end
    end

    private def start_new_clients_handling
      spawn do
        loop do
          if client_socket = @server.accept?
            uuid = UUID.random
            client = Murcure::Client.new(uuid, client_socket, @context)
            handler = Murcure::ClientHandler.new(client, @server_channel)
            
            @clients << { uuid: uuid, client: client, handler: handler, room: 0_i16 }

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
