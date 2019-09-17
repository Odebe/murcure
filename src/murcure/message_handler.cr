module Murcure
  class MessageHandler

    @client : Murcure::Client

    def initialize(client : Murcure::Client)
      @client = client
    end

    def send(type : Symbol, message : Hash)
      type_num = Murcure::ProtosHandler.find_type_number(type)
      proto_resp = Murcure::MessageBuilder.new(type).call(message)
      @client.send(type_num, proto_resp)
    end

    def receive : Murcure::Message
      stack = @client.receive_stack
      
      proto = Murcure::ProtosHandler.find_struct(stack[:type])
      type = Murcure::ProtosHandler.find_type(stack[:type])

      memory = IO::Memory.new(stack[:payload])
      message = proto.from_protobuf(memory)
      
      puts message.inspect

      Murcure::Message.new(message, type)
    end
  end
end
