print("set up wifi mode")
wifi.setmode(wifi.STATION)
sta_ret=file.open('sta.cfg','r')
if sta_ret == nil then
    print 'no station configuration file!'
else
    p=file.readline()
    s=file.readline()
    file.close()
    p=string.sub(p,1,-2)
    s=string.sub(s,1,-2)
    wifi.sta.config(p,s)
    wifi.sta.connect()    
    tmout_count = 0
    tmr.alarm(1, 1000, 1, function()

        if wifi.sta.getip()== nil then
            print("IP unavaiable, Waiting...")
            tmout_count = tmout_count + 1
            if tmout_count > 60 then
                print("prepare to do node.restart()")
                node.restart()                
            end
        else
            tmr.stop(1)
            print("Config done, IP is "..wifi.sta.getip())
            print("mac address is "..wifi.sta.getmac())
            --<<------------------------------
            if wifi.sta.getip() ~= nil then
                dofile('auto.lua')
            else
                print 'getip() nil'
                node.reboot()
            end
            -->>------------------------------         
        end
    end)
end

node.key("long", function()
        tmr.stop(1)
        tmr.stop(6)
        wifi.setmode(wifi.SOFTAP);
        wifi.ap.config({ssid="wifi-iot-node-"..wifi.ap.getmac(),pwd="12345678"});       
        print("prepare to enter telnet server mode!")
        -- a simple telnet server
        s=net.createServer(net.TCP,180) 
        s:listen(2323,function(c) 
           function s_output(str) 
              if(c~=nil) 
                 then c:send(str) 
              end 
           end 
           node.output(s_output, 1)
           c:on("receive",function(c,l) 
              print('receive')
              node.input(l)
              if (conn==nil)    then 
                 print("conn is nil.") 
              end
         
           end) 
           c:on("disconnection",function(c) 
              node.output(nil)
              print('disconnection')
           end) 
           print("Welcome to NodeMcu world.")
        end)
    end)





