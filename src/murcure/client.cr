require "./client_state"

module Murcure
  class Client
    include Murcure::ClientState

    property session_id : UInt32

    # versions
    property version : UInt32?
    property release : String?
    property os : String?
    property os_version : String?
    
    # creds
    property username : String?
    property password : String?
    property tokens : Array(String)?

    # room
    property channel_id : UInt32?

    def initialize(socket : OpenSSL::SSL::Socket::Server)
      super()

      @ch_from_socket = Channel(Protobuf::Message).new
      @ch_from_server = Channel(Protobuf::Message).new
      @socket_reader = ClientSocket.new(socket, @ch_from_socket)

      @rwlock = RWLock.new
      @session_id = Random.rand(UInt32::MIN..UInt32::MAX)
    end

    # def closed?
    #   @socket_reader.closed?
    # end

    # def active?
    #   !closed?
    # end

    def receive : Protobuf::Message?
      @ch_from_socket.receive
    rescue e : Channel::ClosedError
      nil
    end

    def send(msg : Protobuf::Message)
      @socket_reader.send(msg)
    end

    # def close!
    #   @socket_reader.close!
    # end

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