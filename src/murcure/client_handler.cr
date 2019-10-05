module Murcure
  class ClientHandler
    # data from server/other clien
    # @server_channel : Channel(Murcure::Message)
    # data to server/other_client
    # @client_channel : Channel(Murcure::Message)

    # @message_handler : Murcure::MessageHandler
    getter client_channel : Channel(Murcure::Message)

    def initialize(client : Murcure::ClientSocket, server_channel : Channel(Murcure::Message))
      @client = client
      @server_channel = server_channel
      @client_channel = Channel(Murcure::Message).new
      # @message_handler = Murcure::MessageHandler.new(client)
    end

    def call
      spawn handle_messages_from_client
      spawn handle_messages_from_server
    end

    def handle_messages_from_server
      loop do
        message = @client_channel.receive
        case message.type
        when :proto
          case message.subtype.not_nil!
          when :ping
            send_to_client :ping, ping_message
          end
        when :cmd
          case message.subtype.not_nil!
          when :channel_state
            hash = channel_state(message)
            next if hash.nil?

            send_to_client :channel_state, hash
          end
          # TODO
        end
        # puts "\nreceived from main channel in #{message.uuid}:\n#{message.inspect}\n"

      end
    end

    def handle_messages_from_client
      # version = handle_version(@message_handler.receive) 
      # auth_message = handle_auth(@message_handler.receive)

      loop do
        message = @client.receive   
        # puts "received from client socket: #{message.inspect}"
        @server_channel.send(message)
      end
    end

    ## MESSAGES

    # struct ChannelState
    #   include Protobuf::Message
      
    #   contract_of "proto2" do
    #     optional :channel_id, :uint32, 1
    #     optional :parent, :uint32, 2
    #     optional :name, :string, 3
    #     repeated :links, :uint32, 4
    #     optional :description, :string, 5
    #     repeated :links_add, :uint32, 6
    #     repeated :links_remove, :uint32, 7
    #     optional :temporary, :bool, 8, default: false
    #     optional :position, :int32, 9, default: 0
    #     optional :description_hash, :bytes, 10
    #     optional :max_users, :uint32, 11
    #   end
    # end

    def channel_state(message : Murcure::Message) : (Hash(String, (String | UInt32 )) | Nil)
      room_struct = message.data
      return unless room_struct.is_a?(Murcure::RoomStruct)

      { "channel_id" => room_struct.id, "name" => room_struct.name }
    end

    def ping_message : Hash
      { "timestamp" => 9978166 }
    end

    ## SEND

    private def send_to_client(type : Symbol, message : Hash)
      # @message_handler.send(type, message)
      @client.send(type, message)
    end

    ## HANDLE

    private def handle_auth(message)
      message # TODO
    end

    private def handle_version(message)
      message # TODO
    end
  end
end
