module Murcure
  class MessageHandler

    @client : Murcure::Client

    def initialize(client : Murcure::Client)
      @client = client
    end

    def send(message : Murcure::Message)

    end

    def receive
      stack = @client.receive_stack
      
      proto = Murcure::ProtosHandler.find_struct(stack[:type])

      memory = IO::Memory.new(stack[:payload])
      message = proto.from_protobuf(memory)
      puts message.inspect

      Murcure::Message.new(message, Murcure::ProtosHandler.find_type(stack[:type]))
    end
  end
end
