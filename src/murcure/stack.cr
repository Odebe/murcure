module Murcure
  class Stack < BinData
    endian big

    uint16 :type
    uint32 :size
  end
end
