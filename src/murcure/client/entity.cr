require "./state"
require "./socket_reader"
require "../utils/protos"

module Murcure
  module Client
    # Stores parameters of client and provides read\write look to access\modify is` params. 
    class Entity
      include State
  
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
  
      def initialize(ssl_socket : OpenSSL::SSL::Socket::Server)
        super() # state

        @socket = Socket.new(ssl_socket)  

        @rwlock = RWLock.new
        @session_id = Random.rand(UInt32::MIN..UInt32::MAX)
      end

      def connected?
        puts "Client:Entity#connected? => #{@socket.open?}"
        @socket.open?
      end
  
      def receive : Protobuf::Message?
        @socket.receive
      end
  
      def send(msg : Protobuf::Message)
        @socket.send(msg)
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
end
