require './murcure/**/*.cr'

# TODO: Write documentation for `Murcure`
module Murcure
  VERSION = "0.1.0"
  
  server = Murcure::Server.new(123123)
  server.run!
end
