-- temperature control v2.0.1
wifi_config = {}
wifi_config.ssid = 'AIS 4G Hi-Speed Home WiFi_166250'
wifi_config.pwd = '50166250'
wifi_config.auto = false
local id = 1
local host_name = 'http://209.58.180.39/capi/setting/readone.php'
local apiGetSetpoint = 'http://209.58.180.39/capi/setting/readone.php' -- name = temperature
-- local host_name = 'http://192.168.1.130/test/'
local loop = tmr.create()
local delay = tmr.create()
local wifi_status = 0
local server_status = 0
local connection_mode = 0
local tempSetpoint

uart.setup(id, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, {rx = 16, tx = 17})
uart.start(id)


function sendUART(msg)
    uart.write(id, msg)
end

-- Ping server
local function testConnection()
    
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
    }

    body = ''
    http.post(host_name, { headers = headers }, body,
    function(code, data)
        
        if (code < 0) then
            -- print("HTTP request failed")
            server_status = 0 -- Declear server not connect
        else
            server_status = 1 -- Declear server connected
            t = sjson.decode(data)
            for k,v in pairs(t) do
                if k == 'value' then
                    -- print(v)
                end
            end             
        end
    end)
end

function checkConnection ()
    testConnection()
    if wifi_status == 0 then
        connection_mode = 0
    elseif server_status == 0 then
        connection_mode = 1
    else
        connection_mode = 2
    end
end

local function getSetpoint()
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
    }

    body = 'name=temperature'
    http.post(apiGetSetpoint, { headers = headers }, body,
    function(code, data)
        if (code < 0) then
        print("HTTP request failed")
        else
        -- print(code, data)
        t = sjson.decode(data)
        for k,v in pairs(t) do
            if k == 'value' then
                -- print(v)
                tempSetpoint = tonumber(v)
                -- print(tempSetpoint)
            end
        end
        end
    end)
    -- return v
end




-- [[ Create file for record setpoint

--]]
local function saveSetpoint()
    if file.open("setpoint.txt","w+") then
      file.writeline()
      file.close()
    end
end





function lightMode()
    
end

function darkMode()

end


function OfflineMode()

end

function OnlineMode()

end





-- WiFi connection
wifi.mode(wifi.STATION)
wifi.sta.config(wifi_config)
wifi.start()
wifi.sta.on('got_ip', function (ev, info)
    wifi_status = 1
    print('ESP32 config: ', info.ip)
end)
wifi.sta.on('disconnected', function (ev, info)
    wifi_status = 0
    -- print('ESP32 config: ', info.ip)
end)


-- Register auto-repeating 1000 ms (1 sec) timer
loop:register(1000, tmr.ALARM_AUTO, function()
    checkConnection()
    -- print(connection_mode)

    if connection_mode == 2 then
        -- OnlineMode()
        getSetpoint()
        print(tempSetpoint)
        if tempSetpoint == 10 then
            sendUART("10\n")
        elseif tempSetpoint == 11 then
            sendUART("11\n")
        elseif tempSetpoint == 31 then
            sendUART("31\n")
        elseif tempSetpoint == 32 then
            sendUART("32\n")
        elseif tempSetpoint == 33 then
            sendUART("33\n")
        elseif tempSetpoint == 40 then
            sendUART("40\n")
        elseif tempSetpoint == 41 then
            sendUART("41\n")
        end
    else
        OfflineMode()
    end



end)

-- Start timer
-- delay:start()
loop:start()