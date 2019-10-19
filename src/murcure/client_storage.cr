module Murcure
  class ClientStorage
    def initialize
      @mutex = Mutex.new
      @clients = {} of UInt32 => NamedTuple(session_id: UInt32, handler: Murcure::ClientHandler, machine: Murcure::ClientState, attrs: Hash(Symbol, (String | Int32 | UInt32| Symbol | Nil | Array(String))))
    end

    def clients
      @clients
    end

    def add_client(session_id : UInt32, handler : Murcure::ClientHandler, machine : Murcure::ClientState) : Bool
      @clients[session_id] = { session_id: session_id, handler: handler, machine: machine, attrs: {} of Symbol => (String | Int32 | UInt32 | Symbol | Nil | Array(String))}
      true
    end

    def channel(session_id : (UInt32 | Nil))
      raise "session_id cannot be bil" if session_id.nil?

      @clients[session_id.not_nil!][:handler].client_channel
    end

    def get_client(session_id : (UInt32 | Nil))
      raise "session_id cannot be bil" if session_id.nil?

      client = @clients[session_id.not_nil!]
      client || raise "can not find client with session_id='#{session_id.not_nil!}'"
    end

    def update_attr(session_id : (UInt32 | Nil), attr_name : Symbol, attr_value : (String | Int32 | UInt32 | Symbol | Nil | Array(String))) : Bool
      @mutex.synchronize do
        return false if session_id.nil?

        client = @clients[session_id.not_nil!]
        return false unless client

        client[:attrs][attr_name] = attr_value
      end

      true
    end
  end
end