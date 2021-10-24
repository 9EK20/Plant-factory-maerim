-- WiFi connection
local mywifi = {}

function mywifi.toconnect(SSID, PASSWORD)
    wifi.mode(wifi.STATION)
    wifi.sta.config({
    ssid  = SSID,
    pwd   = PASSWORD,
    auto  = false
    })
    wifi.start()
    wifi.sta.connect()
end
return mywifi