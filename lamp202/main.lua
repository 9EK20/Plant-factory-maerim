--lamp202
-- variable configuration

local sw_name = "shelf_3_1"
local SSID = 'AIS 4G Hi-Speed Home WiFi_166250'
local PWD = '50166250'
local apiHostname = "http://209.58.180.39/capi/light2/readone.php"
local name, mainSwitch, subSwitch1, subSwitch2, subSwitch3, subSwitch4
local Ton1, Ton2, Ton3, Ton4
local Toff1, Toff2, Toff3, Toff4
-- ===== wifi config =====
function wificonfig(SSID, PWD)
   wifi.mode(wifi.STATION)
   wifi.sta.config({
      ssid  = SSID,
      pwd   = PWD,
      auto  = false
   })
   wifi.start()
   wifi.sta.connect()
end

local function getSettingVariable()
   headers = {
       ["Content-Type"] = "application/x-www-form-urlencoded",
   }

   body = string.format('%s=%s', 'name',sw_name)
   http.post(apiHostname, { headers = headers }, body,
   function(code, data)
       if (code < 0) then
       print("HTTP request failed")
       else
      --  print(code, data)
       t = sjson.decode(data)
       for k,v in pairs(t) do
           if k == "name" then
               name = v
               -- print(name)
            elseif k == "value" then
               mainSwitch = v
            elseif k == "value_1" then
               subSwitch1 = v
            elseif k == "value_2" then
               subSwitch2 = v
            elseif k == "value_3" then
               subSwitch3 = v
            elseif k == "value_4" then
               subSwitch4 = v
            elseif k == "start_time_1" then
               Ton1 = v
            elseif k == "start_time_2" then
               Ton2 = v
            elseif k == "start_time_3" then
               Ton3 = v
            elseif k == "start_time_4" then
               Ton4 = v
            elseif k == "end_time_1" then
               Toff1 = v
            elseif k == "end_time_2" then
               Toff2 = v
            elseif k == "end_time_3" then
               Toff3 = v
            elseif k == "end_time_4" then
               Toff4 = v
           end
       end
      end
   end)
end






































wificonfig(SSID, PWD)


mytimer = tmr.create()
   mytimer:register(1000, tmr.ALARM_AUTO, function()
      getSettingVariable()
      print(Ton1)
   end)
mytimer:start()