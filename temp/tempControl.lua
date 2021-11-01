--[temperature control.lua]
--initial variable
-- require('include')
local ssid = 'AIS 4G Hi-Speed Home WiFi_166250'
local password = '50166250'
local apiHostname = 'http://209.58.180.39/capi/setting/readone.php'
local status, temp, humi, temp_dec, humi_dec
setpoint = 0

--initial port and pin
local BLUE_LED = 2
local humidifier = 26
local fan = 27
local pin = 4
gpio.config({gpio={BLUE_LED, humidifier, fan}, dir=gpio.OUT })
--gpio.write(BLUE_LED, 0)
gpio.write(humidifier, 0)
gpio.write(fan, 0)

local function getSetpoint()
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
    }

    body = 'name=temperature'
    http.post(apiHostname, { headers = headers }, body,
    function(code, data)
        if (code < 0) then
        print("HTTP request failed")
        else
        -- print(code, data)
        t = sjson.decode(data)
        for k,v in pairs(t) do
            if k == 'value' then
                print(v)
            end
        end
        end
    end)
    return v
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
timer:register(1000, tmr.ALARM_AUTO, function()
    setpoint = getSetpoint()
    -- readHumidity()
    -- print(setpoint)
end)

-- Start timer
timer:start()