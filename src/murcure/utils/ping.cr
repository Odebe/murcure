module Murcure
  module Ping
    # Width	Data type	Value	Comment
    # 4 bytes	int	0	Denotes the request type
    # 8 bytes	long long	ident	Used to identify the reponse.
    class Request < BinData
      endian big
      
      uint32 :type
      uint64 :ident
    end

    # Width	Data type	Value	Comment
    # 4 bytes	int	Version	e.g., \x0\x1\x2\x3 for 1.2.3. Can be interpreted as one single int or four signed chars.
    # 8 bytes	long long	ident	the ident value sent with the request
    # 4 bytes	int	Currently connected users count	
    # 4 bytes	int	Maximum users (slot count)	
    # 4 bytes	int	Allowed bandwidth
    class Response < BinData
      endian big
  
      uint8 :ver_, value: -> { Murcure::VERSION_ARRAY[0] }
      uint8 :ver_maj, value: -> { Murcure::VERSION_ARRAY[1] }
      uint8 :ver_man, value: -> { Murcure::VERSION_ARRAY[2] }
      uint8 :ver_patch, value: -> { Murcure::VERSION_ARRAY[3] }
      
      uint64 :ident
      uint32 :user_count
      uint32 :max_users
      uint32 :bandwidth
    end
  end
end

