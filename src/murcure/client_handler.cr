module Murcure
  class ClientHandler
    def initialize(input_channel : Channel(Murcure::Message), output_channel : Channel(Murcure::Message), client_socket : TCPSocket)
      @client = Murcure::Client.new(client_socket)
      
      @input_channel = input_channel # data from server/other clients
      @output_channel = output_channel # data to server/other_client
    end

    def client_channel
      @client_channel
    end

    def call
      version = handle_version(recieve)
      puts "version: #{version}"

      loop do
        # TODO
      end
    end

    private def recieve
      decode_proto(@client.recieve)
    end

    private def decode_proto(message)
      # TODO
    end

    private def handle_version(message)
      { 
        version: message.version,
        release: message.release,
        os: message.os,
        os_ver: message.os_version,
      } 
    end
  end
end
