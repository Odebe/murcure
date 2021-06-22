# module Murcure
#   module Actors
#     class Client < Earl::SockServer
#       def call(socket)
#         while line = socket.gets
#           # socket.puts(line)
    
#           # TCPServer and UNIXServer automatically flush on LF, but OpenSSL doesn't
#           socket.flush if socket.is_a?(OpenSSL::SSL::Socket::Server)
#         end
#       end
#     end
#   end
# end
