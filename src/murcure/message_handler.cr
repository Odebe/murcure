module Murcure
  class MessageHandler

    @client : Murcure::Client

    def initialize(client : Murcure::Client)
      @client = client
    end

    def recieve
      head_bytes = @client.recieve_head
      body_bytes = @client.recieve_body(calc_body_size(head_bytes))
       
    end

    def call(bytes : Bytes) : Murcure::Message

    end

    private def calc_body_size(head_bytes : Bytes) : Int32
      # TODO
    end
  end
end
