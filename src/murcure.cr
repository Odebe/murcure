require "socket"
require "openssl"
require "bindata"
require "aasm"
require "earl"
require "rwlock"

require "../lib/earl/src/agent"
require "../lib/earl/src/pool_with_state.cr"

require "./murcure/*"
require "./murcure/storage/*"
require "./murcure/actors/*"
require "./murcure/messages/*"

# require "./murcure/message_decorators/*"

# TODO: Write documentation for `Murcure`
module Murcure
  VERSION = "0.1.0"
end

host = "localhost"
port = 12312

# server = Murcure::Server.new(port)
# server.run!
 
ssl_context = OpenSSL::SSL::Context::Server.new
ssl_context.private_key = "key.pem"
ssl_context.certificate_chain = "cert.pem"

server = Murcure::NewServer.new(host, port, ssl_context)
server.call

sleep
