### NTP 服务配置

- 使用本地作为ntp server

  首先要保证本地时间的时区和时间是正确的

  ```shell
  $ timedatectl  status
        Local time: Tue 2018-10-16 13:50:05 CST
    Universal time: Tue 2018-10-16 05:50:05 UTC
          RTC time: Tue 2018-10-16 05:50:08
         Time zone: Asia/Shanghai (CST, +0800)
       NTP enabled: yes
  NTP synchronized: no
   RTC in local TZ: no
        DST active: n/a
  ```

  如果时区不对， 通过下列命令来设置

  ```
  timedatectl set-timezone Asia/Shanghai
  ```

  如果时间不对， 通过以下命令来调整

  ```
  timedatectl set-time HH:MM:SS
  ```

  在server节点上设置其ntp服务器为自身，同时设置可以接受连接服务的客户端，是通过/etc/ntp.conf来实现的。

  ** 注意 server 配置127.127.1.0 表示自己本身 ， restrict 段可以提供接受服务的网段  --> 不要考虑网络问题， 本机有个地址， 是`inet 127.0.0.1/8`

  ```
  server xxx.xxx.xxx.xxx   # 指定ntp服务器的上游ntp服务器为xxx.xxx.xxx.xxx ，并且设置为首选服务器，同步时间为从上到下， 写的越考上，优先级越高，当此服务器同步不了时间，寻找下一个ntp服务器
  server yyy.yyy.yyy.yyy
  server 127.127.1.0	
  fudge 127.127.1.0 stratum 10
  ```















