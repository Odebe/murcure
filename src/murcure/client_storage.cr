module Murcure
  class ClientStorage
    def initialize
      @clients = {} of UUID => NamedTuple(handler: Murcure::ClientHandler, attrs: Hash(Symbol, (String | Int32 | UInt32| Symbol | Nil | Array(String))))
    end

    def add_client(uuid : UUID, handler : Murcure::ClientHandler) : Bool
      @clients[uuid] = { handler: handler, attrs: {} of Symbol => (String | Int32 | UInt32 | Symbol | Nil | Array(String))}
      true
    end

    def channel(uuid : UUID)
      @clients[uuid][:handler].client_channel
    end

    def get_client(uuid : UUID)
      client = @clients[uuid]
      client || raise "can not find client with uuid='#{uuid}'"
    end

    def update_attr(uuid : UUID, attr_name : Symbol, attr_value : (String | Int32 | UInt32 | Symbol | Nil | Array(String))) : Bool
      client = @clients[uuid]
      return false unless client

      client[:attrs][attr_name] = attr_value
      true
    end
  end
end