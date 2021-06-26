require "../client/*"
require "../server/state"
require "../utils/protos"

module Murcure
  module Actors
    class Client
      include Earl::Agent

      def initialize(@server : Server::State, @client : Murcure::Client::Entity)
      end

      def call
        set_default_params!
        auth_step!
        sync_step!
        main_loop!
      end

      def auth_step!
        until @client.auth_ended?
          msg = @client.receive
          break if msg.nil?

          handle(msg)
        end
      end

      def set_default_params!
        @client.write do
          @client.channel_id = @server.default_channel_id
          @server.add_to_room(@client, @server.default_channel_id)
        end
      end

      ### SYNC  

      def sync_step!
        # until client.synchonized?
          send_channels_state
          send_users_state
          send_server_sync

          notify_user_state
        # end

        @client.activate
      end

      def send_channels_state
        channels = @server.channels_state
        channels.each { |ch_state| @client.send(ch_state) }
      end

      def send_users_state
        users = @server.users_state
        users.each { |user_state| @client.send(user_state) }
      end

      def notify_user_state
        m = Murcure::Protos::UserState.new
        m.session = @client.session_id.to_u32
        m.name = @client.username
        m.channel_id = @client.channel_id
        
        @server.users { |users| users.each { |user |user.send(m) } }
      end

      def send_server_sync
        m = Murcure::Protos::ServerSync.new
        m.session = @client.session_id.to_u32
        m.welcome_text = @server.welcome_text
        m.permissions = 1_u64

        @client.send(m)
      end
      
      def main_loop!
        loop do
          msg = @client.receive
          break if msg.nil?

          handle(msg)
        end
      rescue e
        puts e.inspect
        puts e.backtrace.join("\n")
      ensure
        puts "!!! client #{@client.username} disconnected"
      end

      def handle(msg : Murcure::Protos::Version)
        @client.add_version do |c|
          c.version = msg.version
          c.release = msg.release
          c.os = msg.os
          c.os_version = msg.os_version
        end
      end

      def handle(msg : Murcure::Protos::Authenticate)
        @client.add_auth do |c|
          c.username = msg.username.not_nil!
          c.password = msg.password
          c.tokens = msg.tokens
        end
      end

      def handle(message : Murcure::Protos::Ping)
        m = Murcure::Protos::Ping.new
        m.timestamp = message.timestamp

        @client.send(m)
      end

      def handle(message : Murcure::Protos::PermissionQuery)
        message.permissions = 1_u64
        @client.send(message)
      end

      def handle(message : Murcure::Protos::TextMessage)
        rooms = @server.select_rooms(message.channel_id.not_nil!)
        
        new_msg = message.dup
        new_msg.actor = @client.session_id.not_nil!
        
        # TODO: if @server.config.echo?
        # echo = message.dup
        # echo.message = "echo #{message.message}!!!"  
        # @client.send(echo)

        rooms.each do |room|
          room.clients do |clients|
            clients.each do |client|
              client.send(new_msg) if client != @client
            end
          end
        end
      end

      def handle(message : Protobuf::Message)
        puts "!!! unimplimented package : #{message.inspect} !!!"
      end
    end
  end
end
