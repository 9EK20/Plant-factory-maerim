local ssid = 'AIS 4G Hi-Speed Home WiFi_166250'
local password = '50166250'
local apiHostname = 'http://209.58.180.39/capi/co2/update.php'
local co2
id = 1

--initial port and pin
local BLUE_LED = 2
gpio.config({gpio={BLUE_LED, humidifier, fan}, dir=gpio.OUT })

uart.setup(id, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, {rx = 16, tx = 17})
uart.start(id)

function readCO2()
    uart.write(id ,0xFF, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79)
    -- print('sent')
    uart.on(1,"data", 9,
    function(data)
        -- print("%x",string.byte(data, 1, 9))
        H, L = string.byte(data, 3,4)
        -- print(H)
        -- print(L)
        ppm = (H*256)+L
        -- print("CO2 = "..ppm)
        if data=="quit" then
            uart.on("data") -- unregister callback function
        end
    end, 0)
    return ppm
end


local function updateCO2()
    headers = {
      ["Content-Type"] = "application/x-www-form-urlencoded",
    }
    body = string.format('%s=%s', 'co2',tostring(co2))
    http.post(apiHostname, { headers = headers }, body,
      function(code, data)
        if (code < 0) then
          print("HTTP request failed")
        else
          print(data)
        end
      end)
  end


--Connect WiFi
wifi.mode(wifi.STATION)

wifi.sta.config({
    ssid = ssid,
    pwd  = password,
    auto = false
})

wifi.start()
-- wifi.sta.connect()
wifi.sta.on('got_ip', function()
    print('WiFi connected')
    gpio.write(BLUE_LED, 1)
end)

local timer = tmr.create()
-- Register auto-repeating 1000 ms (1 sec) timer
timer:register(30000, tmr.ALARM_AUTO, function()
    co2 = readCO2()
    updateCO2()
    print(co2)
end)

-- Start timer
timer:start()