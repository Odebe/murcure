require "socket"
require "openssl"
require "bindata"
require "uuid"
require "aasm"

require "./murcure/*"
require "./murcure/messages/*"

# require "./murcure/message_decorators/*"

# TODO: Write documentation for `Murcure`
module Murcure
  VERSION = "0.1.0"
  
  server = Murcure::Server.new(12312)
  server.run!
end
