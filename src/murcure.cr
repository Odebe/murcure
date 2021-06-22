require "socket"
require "openssl"
require "bindata"
require "aasm"
require "earl"
require "../lib/earl/src/socket/ssl_server.cr"

require "./murcure/*"
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
 
# ssl_config = { 
#   "key" => "key.pem",
#   "cert" => "cert.pem"
# }

# ssl_context = OpenSSL::SSL::Context::Server.from_hash(ssl_config)

ssl_context = OpenSSL::SSL::Context::Server.new
ssl_context.private_key = "key.pem"
ssl_context.certificate_chain = "cert.pem"

server = Murcure::NewServer.new(host, port, ssl_context)
server.call

sleep
