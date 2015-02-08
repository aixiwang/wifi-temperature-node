---------------------
-- send_to_tcp_server
---------------------
function send_to_tcp_server(server,port,t)
    s1 = string.format('{"key":"1234-5678","cmd":"bsddb_set_ts_data","tag":"data","name":"%s","v":"%s"}',wifi.sta.getmac(),t)   
    s2 = string.format('*%d\r\n%s',string.len(s1),s1)
    print(s2)
    sk=net.createConnection(net.TCP, 0)
    --sk:dns(server,function(conn,ip) 
    --    print(ip)
    sk:connect(port,server)
    sk:send(s2, function(sk) print('send') sk:close() end)
    --end)
end
---------------------
-- ds18_task
---------------------
function ds18_task()
    print 'ds18_task...'
    pin = 2
    ow.setup(pin)
    count = 0
    repeat
      count = count + 1
      addr = ow.reset_search(pin)
      addr = ow.search(pin)
      tmr.wdclr()
    until((addr ~= nil) or (count > 100))
    if (addr == nil) then
      print("No more addresses.")
    else
      print(addr:byte(1,8))
      crc = ow.crc8(string.sub(addr,1,7))
      if (crc == addr:byte(8)) then
        if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
            -- repeat        
            -- print("Device is a DS18S20 family device.")          
              ow.reset(pin)
              ow.select(pin, addr)
              ow.write(pin, 0x44, 1)
              tmr.delay(1000000)
              present = ow.reset(pin)
              ow.select(pin, addr)
              ow.write(pin,0xBE,1)
              print("P="..present)  
              data = nil
              data = string.char(ow.read(pin))
              for i = 1, 8 do
                data = data .. string.char(ow.read(pin))
              end
              -- print(data:byte(1,9))
              crc = ow.crc8(string.sub(data,1,8))
              -- print("CRC="..crc)
              if (crc == data:byte(9)) then
                 t = (data:byte(1) + data:byte(2) * 256) * 625
                 t1 = t / 10000
                 t2 = t % 10000
                 print("T= "..t1.."."..t2.."C")
                 t_str = string.format('%d.%d',t1,t2)
                send_to_tcp_server('115.29.178.81',7777,t_str)
                
              end                   
              tmr.wdclr()
              return
            -- until false              
        else
          print("Device family is not recognized.")
        end
      else
        print("CRC is not valid!")
      end
    end
end

---------------------
-- 180 sec task
---------------------
t_1sec = 179
tmr.alarm(6,1000,1,function()
    tmr.wdclr()
    if (t_1sec < 180) then
        t_1sec = t_1sec + 1
        if (t_1sec >= 180) then
            t_1sec = 0
            print 'ds18_task()'                    
            ds18_task()
        end
    end
end)
                
                
                