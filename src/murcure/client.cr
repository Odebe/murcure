require "./client_state"

module Murcure
  class Client
    include Murcure::ClientState

    def initialize(socket : OpenSSL::SSL::Socket::Server)
      @session_id = Random.rand(UInt32::MIN..UInt32::MAX)
      @ch_from_socket = Channel(Protobuf::Message).new
      @ch_from_server = Channel(Protobuf::Message).new
      @socket_reader = ClientSocket.new(socket, @ch_from_socket)
      @rwlock = RWLock.new
    end

    def receive : Protobuf::Message
      @socket_reader.receive
    end

    def send(msg : Protobuf::Message)
      @socket_reader.send(msg)
    end

    def close!
      @socket_reader.close!
    end

    def add_version
      write do 
        yield self

        fire(:add_version)
      end
    end

    def add_auth
      write do 
        yield self

        fire(:add_auth)
      end
    end

    def activate
      write { fire(:activate) }
    end

    def read
      @rwlock.read { yield }
    end

    def write
      @rwlock.write { yield }
    end
  end
end
