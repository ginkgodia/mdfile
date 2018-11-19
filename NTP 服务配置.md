### NTP 服务配置

- 使用本地作为ntp server

  *** 时间同步方式ntpdate 强制同步和ntpd 服务自身平滑同步

  如果在生产环境中，一定不要强制使用ntpdate 强制同步， 需要使用ntpd 平滑自动同步

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

  ** 注意 server 配置127.127.1.0 表示自己本身 ， restrict 段可以提供接受服务的网段  --> 不要考虑网络问题， 127.127.1.0 本身不参与通信，仅表示自身是本地ntp server

  ```bash
  server xxx.xxx.xxx.xxx   # 指定ntp服务器的上游ntp服务器为xxx.xxx.xxx.xxx ，并且设置为首选服务器，同步时间为从上到下， 写的越考上，优先级越高，当此服务器同步不了时间，寻找下一个ntp服务器
  server yyy.yyy.yyy.yyy
  server 127.127.1.0	#local clock 如果上边的服务器都无法同步时间，就和本地系统时间同步， 127.127.1.0 是一个ip地址，不是网段，因为掩码为8.
  fudge 127.127.1.0 stratum 10 #127.127.1.0为第十层， ntp和127.127.1.0 同步完后，就变成了11层， ntp 是层次阶级的， 同步上层服务器的stratum大小不能超过或等于16
  # 把通过GPS（Global Positioning System，全球定位系统）取得发送标准时间的服务器叫Stratum-1的NTP服务器，而Stratum-2则从Stratum-1获取时间，Stratum-3从Stratum-2获取时间，以此类推，但Stratum层的总数限制在15以内。所有这些服务器在逻辑上形成阶梯式的架构相互连接，而Stratum-1的时间服务器是整个系统的基础
  restrict 10.10.10.0 mask 255.255.255.0 #允许网段访问
  restrict 10.10.10.10  #允许ip访问
  
  ```

  ntp server 标准配置文件

  ```shell
  #grep -vE '^#|^$' /etc/ntp.conf
  driftfile /var/lib/ntp/drift
  restrict default kod nomodify notrap nopeer noquery
  restrict -6 default kod nomodify notrap nopeer noquery
  restrict 127.0.0.1
  restrict -6 ::1
  server 0.centos.pool.ntp.org
  server 1.centos.pool.ntp.org
  server 2.centos.pool.ntp.org
  includefile /etc/ntp/crypto/pw
  keys /etc/ntp/keys
  ```

  配置详解：

  ```
  driftfile 选项 指定了用来保存系统时钟频率偏差的文件，ntpd程序会使用它来自动地补偿时钟的自然漂移，从而使时钟即使在切断了外来时源的情况下仍能保持相当的准确度。 另外driftfile选项也保存上一次相应所使用的ntp服务器的信息。
  ```

  ```
  restrict default kod nomodify notrap nopeer noquery 默认拒绝所有ntp客户端的操作， restrict <子网掩码> |<网段> [ignore|nomodiy|notrap|notrap|notrust|nknod]可以指定通信的网段和地址，如果没有指定，说明客户端访问NTP服务器没有任何限制
       - ignore 关闭所有ntp服务
       - nomodiy 表示客户端不能更改NTP服务器的时间，但可以通过NTP服务器进行时间同步
       - notrust 拒绝没有通过认证的客户端
       - knod kod 阻止‘Kiss of Death’ 包（一种DOS）攻击对服务器的破坏，使用knod功能
       - nopeer 不与其他同一层的NTP服务器进行同步
  ```

  ```
  server [IP|FQDN|prefer] 指该服务器上层NTP Server，使用prefer的优先级最高，没有使用prefer则按照配置文件顺序由高到低，默认情况下至少15min和上层NTP服务器进行时间校对
  ```

  ```
  fudge 可以指定本地NTP Server层，如fudge 127.0.0.1 stratum 9
  ```

  ```
  broadcast 网段 掩码 指定NTP进行时间广播的网段
  ```

  ```
  logfile  可以指定NTP Server 日志文件
  ```

  几个与NTP 相关的配置文件

  ```
  /usr/share/zoneinfo/  存放时区文件目录
  /etc/sysconfig/clock 指定当前系统时区信息
  /etc/localtime  相应的时区文件
  ```

  如果需要修改当前时区， 可以从存放时区文件的目录中拷贝对应时区文件覆盖/etc/localtime 并修改/etc/sysconfig/clock 即可

- ntp 客户端

  ```
  server xxx.xxx.xxx.xxx # server 指定需要同步server的地址
  ```

- ntp 命令行校验工具

  - ntpq 列出上层状态

    ```
    ntpq -np  #指令可以列出目前我们的NTP与相关上层NTP的状态
    # ntpq -np
         remote           refid      st t when poll reach   delay   offset  jitter
    ==============================================================================
    *127.127.1.0     .LOCL.          10 l   58   64  377    0.000    0.000   0.000
    ```

    输出说明：

    ```
    remote  ntp server 
    refid 参考的上层ntp地址， 如果为.LocL. 表示是本地ntp server
    st 层次
    when 上次更新时间距离现在时长
    poll 下次更新时间
    reach 更新次数
    delay 延迟
    offset 时间补偿结果
    jitter 与BIOS硬件时间差异
    ```


| 位置       | 标志        | 含义                                                         |
| ---------- | :----- | ------------------------------------------------------------ |
| remote之前 | *           | 当前作为优先主从同步对象的远程节点或服务器           |
|            | +           | 良好的且优先使用的远程节点或服务器                 |
|            | blank(空格) | 没有响应的NTP服务器                                          |
| | # | 良好的远程节点或服务器但是未被使用（不在按同步距离排序的前六个节点中，作为备用节点使用） |
| 列表上方   | remote      | 响应这个请求的NTP服务器的名称                                |
|            | refid       | NTP服务器使用的更高一级服务器的名称  .locl. 本机              |
|            | st          | 正在响应请求的NTP服务器的级别                                |
|            | when        | 上一次成功请求之后到现在的秒数                               |
|            | poll        | 本地和远程服务器多少时间进行一次同步，单位秒，在一开始运行NTP的时候这个poll值会比较小，服务器同步的频率大，可以尽快调整到正确的时间范围，之后poll值会逐渐增大，同步的频率也就会相应减小 |
|            | reach       | 用来测试能否和服务器连接，是一个八进制值，每成功连接一次它的值就会增加 |
|            | delay       | 从本地机发送同步要求到ntp服务器的往返时间                    |
|            | offset      | 主机通过NTP时钟同步与所同步时间源的时间偏移量，单位为毫秒，offset越接近于0，主机和ntp服务器的时间越接近 |
|            | jitter      | 统计了在特定个连续的连接数里offset的分布情况。简单地说这个数值的绝对值越小，主机的时间就越精确 |

  - ntpstat 查看同步状态

    ```
    
    # ntpstat
    synchronised to local net at stratum 11 
       time correct to within 11 ms
       polling server every 64 s
    
    ```

  - ntpdate 同步当前时间

    ```
    ntpdate NTPSERVER地址
    ntpdate -d serverip 调试查看原因
    注意： 如果配置的为本地的话，server 一般为172.172.1.0 但是你用serverip 一定不是172. 这个ip。必须为正常的网卡地址
    ```

    ```
    # 
    [root@node-1 ~]# ntpdate -d 192.168.10.3
    16 Oct 17:41:35 ntpdate[227973]: ntpdate 4.2.6p5@1.2349-o Mon Nov 14 18:25:09 UTC 2016 (1)
    Looking for host 192.168.10.3 and service ntp
    host found : node-1
    transmit(192.168.10.3)
    receive(192.168.10.3)
    transmit(192.168.10.3)
    receive(192.168.10.3)
    transmit(192.168.10.3)
    receive(192.168.10.3)
    transmit(192.168.10.3)
    receive(192.168.10.3)
    server 192.168.10.3, port 123
    stratum 11, precision -24, leap 00, trust 000
    refid [192.168.10.3], delay 0.02565, dispersion 0.00000
    transmitted 4, in filter 4
    reference time:    df7030d3.f2b7e0ba  Tue, Oct 16 2018 17:41:39.948
    originate timestamp: df7030d5.53762b44  Tue, Oct 16 2018 17:41:41.326
    transmit timestamp:  df7030d5.53712688  Tue, Oct 16 2018 17:41:41.325
    filter delay:  0.02567  0.02568  0.02565  0.02568 
             0.00000  0.00000  0.00000  0.00000 
    filter offset: 0.000001 -0.00001 -0.00000 -0.00001
             0.000000 0.000000 0.000000 0.000000
    delay 0.02565, dispersion 0.00000
    offset -0.000005
    
    16 Oct 17:41:41 ntpdate[227973]: adjust time server 192.168.10.3 offset -0.000005 sec
    ```

  - ntpdate -u server 

    ```
    使用无特权的端口发送数据包， 这在防火墙阻止特权端口的数据时很有用， 你可以和防火墙之外的主机同步
    ```












