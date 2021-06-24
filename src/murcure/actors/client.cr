module Murcure
  module Actors
    class Client
      include Earl::Agent

      def initialize(@server : Murcure::ServerState, @client : Murcure::Client)
      end

      def call
        auth_step!
        set_default_params!
        sync_step!
        main_loop!
      end

      def auth_step!
        until @client.auth_ended?
          handle(@client.receive)
        end
      end

      def set_default_params!
        @client.write do
          @client.channel_id = @server.default_channel_id
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

        client.activate
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
        
        users = @server.users_list
        users.each { |user| user.send(m) }
      end

      def send_server_sync
        m = Murcure::Protos::ServerSync.new
        m.session = @client.session_id.to_u32
        m.welcome_text = @server.welcome_text
        m.permissions = 123123_u64

        @client.send(m)
      end
      
      def main_loop!
        while running? && @client.active?
          handle(@client.receive)
        end
      end

      def handle(msg : Murcure::Protos::Version)
        @client.add_version do |c|
          c.version = msg.version
          c.release = msg.relese
          c.os = msg.os
          c.os_version = msg.os_version
        end
      end

      def handle(msg : Murcure::Protos::Authenticate)
        @client.add_auth do |c|
          c.username = msg.username
          c.password = msg.password
          c.tokens = msg.tokens
        end
      end

      def handle(message : Murcure::Protos::Ping)
        m = Murcure::Protos::Ping.new
        m.timestamp = 123123

        @client.send(m)
      end

      def handle(message : Protobuf::Message)
        puts "unimplimented package"
      end
    end
  end
end
