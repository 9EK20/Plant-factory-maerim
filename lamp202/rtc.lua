-- RTC module
-- initial port
local id, sda, scl, device = 0, 21, 22, 0x68
local rtctime, rtcdate, rtcHr, rtcMin

local function getRtc()
   i2c.setup(id, sda, scl, i2c.SLOW)
   i2c.start(id)
   i2c.address(id, device, i2c.TRANSMITTER)
   i2c.write(id, 0)
   i2c.stop(id)
   i2c.start(id)
   i2c.address(id, device, i2c.RECEIVER)
   c = i2c.read(id, 7)  -- Read 7 bytes of data
   i2c.stop(id)
 
   rtctime = string.format("%02x:%02x:%02x",string.byte(c, 3)
     ,string.byte(c, 2),string.byte(c, 1))
   rtcdate =  string.format("%02x-%02x-%02x",string.byte(c, 5)
     ,string.byte(c, 6),string.byte(c, 7))
   rtcHr = tonumber(string.sub(rtctime,1,-7))
   rtcMin = tonumber(string.sub(rtctime,4,-4))
   -- print(rtctime)
   return rtctime
 end