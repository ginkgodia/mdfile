```
戴尔服务器R710及以下版本可以通过在启动过程中按ctrl + E来进入IPMI设置

戴尔R720 需要在系统启动时按F2, 进入System Setup 界面， 选择iDRAC Settings
```

进去后， 选择配置Network， 

![](C:\Users\qc.wu\Pictures\idrac-config.png)

在这个配置中配置下列内容：

![](C:\Users\qc.wu\Pictures\choose_network.png)

-  iDRAC网卡的启用    ---enable

![](C:\Users\qc.wu\Pictures\enable_idrc.png)

- 选择Nic 网卡

  如果服务器启用了idrac卡,在`Nic Selection`可以看到这个`Dedicated`的专用网卡,否则只能看到`LOM1`,`LOM2`(为`Lan Of MotherBoard`的缩写)这样的配置。没有这个只是功能缩减了一点,其余的配置依然相同

- 然后在ipv4选项中配置IP地址，网关，和掩码

![](C:\Users\qc.wu\Pictures\set_idrac_ip.png)

其他部分按照正常配置即可

- 一般和dhcp和动态的部分都需要关闭

- VLAN 部分如果有划分vlan，那么需要配置，否则禁用即可

- 然后进入到用户配置部分添加用户名和密码

  ![](C:\Users\qc.wu\Pictures\user_confuguration.png)

![](C:\Users\qc.wu\Pictures\set_user_passwd.png)



![](C:\Users\qc.wu\Pictures\set_user_passwd.png)

```
# 先安装ipmitool apt-get install -y openipmi ipmitool # 启动openimpi服务,否则会报错 service openipmi start
```

接下来就直接执行了

```
# ipmitool -I <open|lan|lanplus> -U <user> -P <passwd> command ipmitool -I open ipmitool -I lanplus .. chassis power staus
```









ipmi  使用介绍

1. IPMI网口： 

   **共用第一个网口或者使用iDRAC的网口**


