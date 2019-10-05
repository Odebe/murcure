module Murcure
  class ClientStorage
    def initialize
      @clients = {} of UUID => NamedTuple(handler: Murcure::ClientHandler, machine: Murcure::ClientState, attrs: Hash(Symbol, (String | Int32 | UInt32| Symbol | Nil | Array(String))))
    end

    def add_client(uuid : UUID, handler : Murcure::ClientHandler, machine : Murcure::ClientState) : Bool
      @clients[uuid] = { handler: handler, machine: machine, attrs: {} of Symbol => (String | Int32 | UInt32 | Symbol | Nil | Array(String))}
      true
    end

    def channel(uuid : (UUID | Nil))
      raise "uuid cannot be bil" if uuid.nil?

      @clients[uuid.not_nil!][:handler].client_channel
    end

    def get_client(uuid : (UUID | Nil))
      raise "uuid cannot be bil" if uuid.nil?

      client = @clients[uuid.not_nil!]
      client || raise "can not find client with uuid='#{uuid.not_nil!}'"
    end

    def update_attr(uuid : (UUID | Nil), attr_name : Symbol, attr_value : (String | Int32 | UInt32 | Symbol | Nil | Array(String))) : Bool
      return false if uuid.nil?

      client = @clients[uuid.not_nil!]
      return false unless client

      client[:attrs][attr_name] = attr_value
      true
    end
  end
end