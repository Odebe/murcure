module Murcure
  struct ClientStruct
    alias Attributes = (String | Int32 | UInt32| Symbol | Nil | Array(String))

    getter session_id : UInt32
    getter handler : Murcure::ClientHandler
    getter machine : Murcure::ClientState
    getter attrs : Hash(Symbol, Attributes)

    def initialize(@session_id, @handler, @machine, @attrs = {} of Symbol => Attributes); end
  end

  class Client
    alias Attributes = (String | Int32 | UInt32| Symbol | Nil | Array(String))

    getter session_id : UInt32
    getter handler : Murcure::ClientHandler
    getter machine : Murcure::ClientState
    getter attrs : Hash(Symbol, Attributes)

    def initialize(@session_id, @handler, @machine, @attrs = {} of Symbol => Attributes); end

    def call!

    end
  end
end
