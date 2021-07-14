require "socket"
require "openssl"
require "bindata"
require "aasm"
require "earl"
require "rwlock"
require "totem"

require "../lib/earl/src/artist.cr"
require "../lib/earl/src/agent.cr"

require "./murcure/versions"
require "./murcure/options"
require "./murcure/server/config"
require "./murcure/server/tcp"
require "./murcure/server/udp"

Murcure::Options.parse!

config = Murcure::Server::Config.configure do |c|
  c.set_default "host", "0.0.0.0"
  c.set_default "port", 64738
  c.set_default "private_key_path", "key.pem"
  c.set_default "cert_path", "cert.pem"  
end

ssl_context = OpenSSL::SSL::Context::Server.new
ssl_context.private_key = config.private_key_path
ssl_context.certificate_chain = config.cert_path

state = Murcure::Server::State.new(config)

tcp_server = Murcure::Server::Tcp.new(config.host, config.port, ssl_context, state)
spawn { tcp_server.start! }

if config.enable_udp
  udp_server = Murcure::Server::Udp.new(config.host, config.port, ssl_context, state)
  spawn { udp_server.start! }
end

sleep
