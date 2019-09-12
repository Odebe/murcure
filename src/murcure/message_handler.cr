module Murcure
  class MessageHandler

    @client : Murcure::Client

    def initialize(client : Murcure::Client)
      @client = client
    end

    def receive
      head_bytes = @client.receive_head
      body_bytes = @client.receive_body(calc_body_size(head_bytes))
       
    end

    def call(bytes : Bytes) : Murcure::Message
    end

    private def calc_body_size(head_bytes : Bytes) : Int32
      # TODO
      0
    end
  end
end
