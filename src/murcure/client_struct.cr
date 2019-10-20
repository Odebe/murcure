module Murcure
  struct ClientStruct
    alias Attributes = (String | Int32 | UInt32| Symbol | Nil | Array(String))

    getter session_id : UInt32
    getter handler : Murcure::ClientHandler
    getter machine : Murcure::ClientState
    getter attrs : Hash(Symbol, Murcure::ClientStruct::Attributes)

    def initialize(@session_id, @handler, @machine, @attrs); end
  end
end