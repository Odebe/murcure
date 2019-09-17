module Murcure
  class MessageBuilder
    def initialize(type : Symbol)
      @type = type
    end

    def call(data : Hash)
      message = process_message(@type, data)
      memory = IO::Memory.new
      message.to_protobuf(memory)
      bytes = Bytes.new(memory.bytesize)
      memory.read(bytes)
      bytes
    end

    def process_message(type, data)
      case type
      when :ping
        process_ping_message(data)
      else
        raise "not defined message"
      end
    end

    def process_ping_message(data)
      m = Murcure::Protos::Ping.new
      m.timestamp = data["timestamp"].to_u64
      m
      # m.good = 1
      # m.late = 1
      # m.lost = 0
      # m.resync = 0
      # m.udp_packets = 1
      # m.tcp_packets = 0
      # m.udp_ping_avg = 0.0
      # m.udp_ping_var = 0.0
      # m.tcp_ping_avg = 0.0
      # m.tcp_ping_var = 0.0
      # m
    end
  end
end
