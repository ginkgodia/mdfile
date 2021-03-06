#SUM

## ++TOOLS++

###Shadowsocks
    - 错误1.  `undefined symbol EVP_CIPHER_CTX_cleanup`
    
      产生原因:
    
      在openssl1.1.0 版本中废弃了EVP_CIPHER_CTX_cleanup 函数, 并使用EVP_CIPHER_CTX_RESET函数代替了
    
      解决办法: 
    
      找到程序所使用的openssl.py 文件, 然后将文件中的所有EVP_CIPHER_CTX_cleanup  替换为EVP_CIPHER_CTX_RESET即可
    
      但是由于在linux中, 由于多租户的原因,可能使用的openssl.py文件并不是系统默认的文件,所以,要找到程序启动时用的文件
    
      方法: 使用strace 命令追踪该进程的系统调用
    
      `sudo  strace -f  -o out sudo ssserver  -c ss/ss.json  -d start`
    
      在输出结果中找到启动时所应用的文件为: 
    
      `openat(AT_FDCWD, "/home/ginkgo/.local/lib/python2.7/site-packages/shadowsocks/crypto/openssl.py", O_RDONLY) = 7`
    
      然后将该文件中的clean_up 函数替换为reset 即可
    
    - 错误2.  `socket.error: [Errno 99] Cannot assign requested address`
    
      场景1. 在利用阿里云服务器来搭建ssserver服务时
    
      `由于阿里云所提供的公网ip地址是弹性公网IP(Elastic IP Address), 弹性公网IP是一种NAT IP, 它实际上位于阿里云的公网网关上, 通过NAT 方式映射到了被绑定的ECS实例位于私网网卡上, 因此, 绑定了弹性公网IP的专有网络ECS实例可以直接使用这个IP进行公网通信但是在ECS实例的网卡上并不能看到这个IP地址。`
    
      在配置ss.json 时, 将ip地址错配成了公网ip, 所以提示报错
    
      发现该错误的方法: 
    
      1.  指定日志文件 ` --log-file LOG_FILE    log file for daemon mode`
      2. 使用strace 跟踪 `read(5, "e operation timed out.\"\n    erro"..., 4096) = 4096`
    
      该错误表示使用提供的ip地址来建立socket ,读取文件描述符失败
    
      场景2. 在错误使用客户端错误使用ssserver
    
      由于长时间未使用ss, 导致在启动服务时, 随手敲ssserver -c  xx -d start , 一直启动失败, 报错. 后发现用错了命令
    
      其根因也是因为本机上没有配置中提供的ip地址, 所以错误同第一次

###创建用户

	ubuntu 下创建用户
	
	1. 创建用户
	
	- useradd:  Linux 下一个创建用户的命令
	- adduser:  一个Perl 脚本, 其功效一致
	
	1. 创建用户无家目录
	
	- 使用useradd -d 制定用户家目录时要保证家目录文件存在, 且要将该家目录的属主属组属于该用户
	- 如果想在创建时一并创建家目录, 需要制定-m 参数, 创建家目录
	
	1. 创建用户登录后不显示主机名
	
	- 不显示主机名是因为没有指定该用户的登录方式, 使用-s 参数指定登录shell 即可
	
	所以, 在ubuntu 创建用户命令:  
	useradd -m -ppasswd -s /bin/bash username 

### yum源

RedHat yum源是收费的，没有成功注册RH的机器是不能正常使用yum的， 它的yum 源需要注册付费， 一般采用centos的源来替代或者在本地用本地镜像来做本地源。

提示如下：

```
This system is not registered to Red Hat Subscription Management. You can use subscription-manager to register.
Cleaning repos: base extras updates
```



本次采用centos源来代替redhat源

首先要删除redhat 默认的yum 软件和版本包和一个python 包

```shell
# rpm -qa |grep yum
yum-utils-1.1.31-2.2.noarch
yum-metadata-parser-1.1.4-10.el7.x86_64
yum-3.4.3-132.el7.noarch
yum-rhn-plugin-2.0.1-5.el7.noarc
python-urlgrabber-3.10-8.el7.noarch
```

和一个系统版本包，不然会报错：

```
file /etc/os-release from install of centos-release-7-5.1804.5.el7.centos.x8
......
和其他类似报错
```

需要卸载`rpm -qa |grep redhat-release`

然后执行删除操作:

```
rpm -aq|grep yum|xargs rpm -e --nodeps
rpm -qa |grep redhat-release |xargs rpm -e  --nodeps
```

一定要记录这原来系统的rpm 包的版本号， yum 版本和Yum-utils版本一定要一致

然后从网络上下载对应的版本包安装成功即可替换系统yum软件

--- 注意： 一定不要替换掉系统的rpm包， 不然就GG了。

安装阿里的yum 源

```shell
wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
```

然后替换掉软件源中的变量，否则报错：

```shell
for i in `ls`;do sed -i 's/\$releasever/7/' $i;done
for i in `ls`;do sed -i 's/\$contentdir/centos-7/' $i;done
否则报如下错误：
One of the configured repositories failed (CentOS-$releasever - Base - mirrors.aliyun.com),
```

执行yum clean all 

yum makecache

### ssh

1. ssh username@hostname 和ssh hostname的区别

   ssh username@hostname 表示使用username的帐户登陆到机器上

   ssh hostname 时先用$HOME/.ssh/config 和/etc/ssh/ssh_config 配置文件中获取以什么帐户登陆到hostname上去，如果没有配置，那么尝试用本机当前帐户登陆

   `.ssh/config`

   ```
   Host 别名
       Hostname 主机名
       Port 端口
       User 用户名
    chmod 600 .ssh/config 
   ```

2. ssh 参数

   ```
   ssh -CT -o BatchMode=yes node3
   -C 请求压缩所有数据
   -T 意思是说禁止分配伪终端。当用ssh或telnet等登录系统时，系统分配给我们的终端就是伪终端。
   如果ssh使用此选项登录系统时，由于禁用，将无法获得终端；但仍能够获得shell，只不过看起来像在本地，也没有很多应有的环境变量，例如命令提示符，PS1等。
   当使用命令ps -ef|grep [b]ash时看到root 22082 22080 0 11:51 ? 00:00:00 -bash显示终端那里是一个问号
   
   -o BatchMode 当BatchMode=yes时，表示将不会显示交互式口令输入，而是直接失败，从而避免批处理的时候卡住。当BatchMode=no时，将会提示用户输入密码。
   -o StrictHostKeyChecking=yes|no|ask
   StrictHostKeyChecking有两种功能，一是是否会自动地将远程主机的公钥记录到known_hosts中，二是当远程主机的公钥变化了，是否允许本地主机进行登录。当StrictHostKeyChecking=no时，表示在连接远程主机时，会主动把对方的公钥加到known_hosts中，而不会提示用户是否要记录这样的信息，且当远程主机的公钥变化了，仍然会连接上，不会出现因为公钥不对连接失败
   ```

3. ssh 免密码交互

   ```
   1. 建立信任关系
   2. 使用sshpass工具
   3. expect
   ```

### yum 

1. 添加源

```
yum install -y yum-utils && sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/
```

2. 设置源的优先级

`yum install -y yum-plugin-priorities`

```
/etc/yum.repos.d/local.repo
    [local]
    name=local
    baseurl=file:///opt/centos
    enabled=1
    gpgcheck=0
    priority=1
    #在原基础上加入priority=1 ；数字越小优先级越高
    #可以继续修改其他源的priority值，经测试仅配置本地源的优先级为priority=1就会优先使用本地源了
```

3. yum fastestmirror

   ```
   1.修改插件的配置文件
   
   # vi  /etc/yum/pluginconf.d/fastestmirror.conf  
   
   enabled = 1//由1改为0，禁用该插件
   
   2.修改yum的配置文件
   
   # vi /etc/yum.conf
   
   plugins=1//改为0，不使用插件
   
   yum --disableplugin=fastestmirror update
   ```


### vmstat

vmstat 用来获得有关进程，虚拟内存，内存交换空间及cpu 活动的信息，这些信息用来反映系统的负载情况

在系统中运行的每个进程都需要使用到内存，但不是每个进程都需要每时每刻使用系统分配的内存空间。当系统运行所需内存超过实际的物理内存，内核会释放某些进程所占用但未使用的部分或所有物理内存，将这部分资料存储在磁盘上直到进程下一次调用，并将释放出的内存提供给有需要的进程使用。

在Linux内存管理中，主要是通过“调页Paging”和“交换Swapping”来完成上述的内存调度。调页算法是将内存中最近不常使用的页面换到磁盘上，把活动页面保留在内存中供进程使用。交换技术是将整个进程，而不是部分页面，全部交换到磁盘上。

分页(Page)写入磁盘的过程被称作Page-Out，分页(Page)从磁盘重新回到内存的过程被称作Page-In。当内核需要一个分页时，但发现此分页不在物理内存中(因为已经被Page-Out了)，此时就发生了分页错误（Page Fault）。

当系统内核发现可运行内存变少时，就会通过Page-Out来释放一部分物理内存。经管Page-Out不是经常发生，但是如果Page-out频繁不断的发生，直到当内核管理分页的时间超过运行程式的时间时，系统效能会急剧下降。这时的系统已经运行非常慢或进入暂停状态，这种状态亦被称作thrashing(颠簸)

```
vmstat
-a 显示活跃内存和非活跃内存
-f 显示系统启动至今的fork 数量
-w 可以扩大字段长度，当内存较大时，默认长度不够完全展示内存
-n 只在开始时显示一次各字段的名称
delay 刷新时间间隔，如果不指定，只显示一条结果
count 刷新次数，如果不指定刷新次数，但指定了刷新间隔， 将刷新无穷次
-d 显示磁盘相关统计信息
-S 使用指定单位显示， 参数有k, K, m, M 分表1000， 1024， 100000， 1048576
```

```shell
ex:
# vmstat -aw 1 3 -S k 
procs -----------------------memory---------------------- ---swap-- -----io---- -system-- --------cpu--------
 r  b         swpd         free        inact       active   si   so    bi    bo   in   cs  us  sy  id  wa  st
 5  0            0       342102       400613      2939854    0    0    27    87  851 1278  13   2  84   1   0
 0  0            0       342102       400613      2939887    0    0     0    14  751 1100  10   3  86   0   0
 0  0            0       342069       400617      2939900    0    0     4    14  813 1211  10   1  85   3  
```

| **类别**                | **项目**       | **含义**                                   | **说明**                                                     |
| ----------------------- | -------------- | ------------------------------------------ | ------------------------------------------------------------ |
| **Procs**（进程）       | r              | 等待执行的任务数                           | 展示了正在执行和等待cpu资源的任务个数。当这个值超过了cpu个数，就会出现cpu瓶颈。 |
|                         | b              | 等待IO的进程数量                           |                                                              |
| **Memory(**内存)        | swpd           | 正在使用虚拟的内存大小，单位k              |                                                              |
|                         | free           | 空闲内存大小                               |                                                              |
|                         | buff           | 已用的buff大小，对块设备的读写进行缓冲     |                                                              |
|                         | cache          | 已用的cache大小，文件系统的cache           |                                                              |
|                         | 活跃的内存大小 | 具体含义见：概念补充（当使用-a选项时显示） |                                                              |
|                         | active         | 活跃的内存大小                             | 具体含义见：概念补充（当使用-a选项时显示）                   |
| **Swap**                | si             | 每秒从交换区写入内存的大小（单位：kb/s）   |                                                              |
|                         | so             | 每秒从内存写到交换区的大小                 |                                                              |
| **IO**                  | bi             | 每秒读取的块数（读磁盘）                   | 现在的Linux版本块的大小为1024bytes                           |
|                         | bo             | 每秒写入的块数（写磁盘）                   |                                                              |
| **system**              | in             | 每秒中断数，包括时钟中断                   | 这两个值越大，会看到由内核消耗的cpu时间会越多                |
|                         | cs             | 每秒上下文切换数                           |                                                              |
| **CPU**（以百分比表示） | Us             | 用户进程执行消耗cpu时间(user time)         | us的值比较高时，说明用户进程消耗的cpu时间多，但是如果长期超过50%的使用，那么我们就该考虑优化程序算法或其他措施了 |
|                         | Sy             | 系统进程消耗cpu时间(system time)           | sys的值过高时，说明系统内核消耗的cpu资源多，这个不是良性的表现，我们应该检查原因。 |
|                         | Id             | 空闲时间(包括IO等待时间)                   |                                                              |
|                         | wa             | 等待IO时间                                 | Wa过高时，说明io等待比较严重，这可能是由于磁盘大量随机访问造成的，也有可能是磁盘的带宽出现瓶颈 |

```
procs
r 列表示运行和等待cpu时间片的进程数，如果长期大于1，说明cpu不足，需要增加cpu。当这个值超过了CPU数目，就会出现CPU瓶颈了。
b 列表示在等待资源的进程数，比如正在等待I/O、或者内存交换等。

cpu 表示cpu的使用状态
us 列显示了用户方式下所花费 CPU 时间的百分比。us的值比较高时，说明用户进程消耗的cpu时间多，但是如果长期大于50%，需要考虑优化用户的程序。
sy 列显示了内核进程所花费的cpu时间的百分比。这里us + sy的参考值为80%，如果us+sy 大于 80%说明可能存在CPU不足。系统CPU时间，如果太高，表示系统调用时间长，例如是IO操作频繁。
wa 列显示了IO等待所占用的CPU时间的百分比。这里wa的参考值为30%，如果wa超过30%，说明IO等待严重，这可能是磁盘大量随机访问造成的，也可能磁盘或者磁盘访问控制器的带宽瓶颈造成的(主要是块操作)。 
id 列显示了cpu处在空闲状态的时间百分比。空闲 CPU时间，一般来说，id + us + sy = 100,一般我认为id是空闲CPU使用率，us是用户CPU使用率，sy是系统CPU使用率。

system 显示采集间隔内发生的中断数
in 列表示在某一时间间隔中观测到的每秒设备中断数。
cs列表示每秒产生的上下文切换次数，如当 cs 比磁盘 I/O 和网络信息包速率高得多，都应进行进一步调查。每秒上下文切换次数，例如我们调用系统函数，就要进行上下文切换，线程的切换，也要进程上下文切换，这个值要越小越好，太大了，要考虑调低线程或者进程的数目,例如在apache和nginx这种web服务器中，我们一般做性能测试时会进行几千并发甚至几万并发的测试，选择web服务器的进程可以由进程或者线程的峰值一直下调，压测，直到cs到一个比较小的值，这个进程和线程数就是比较合适的值了。系统调用也是，每次调用系统函数，我们的代码就会进入内核空间，导致上下文切换，这个是很耗资源，也要尽量避免频繁调用系统函数。上下文切换次数过多表示你的CPU大部分浪费在上下文切换，导致CPU干正经事的时间少了，CPU没有充分利用，是不可取的。

memory
swpd 切换到内存交换区的内存数量(k表示)。如果swpd的值不为0，或者比较大，比如超过了100m，只要si、so的值长期为0，系统性能还是正常。否则，表示你的机器物理内存不足了，如果不是程序内存泄露的原因，那么你该升级内存了或者把耗内存的任务迁移到其他机器。
free 当前的空闲页面列表中内存数量(k表示) 
buff 作为buffer cache的内存数量，一般对块设备的读写才需要缓冲。 
cache: 作为page cache的内存数量，一般作为文件系统的cache，如果cache较大，说明用到cache的文件较多，如果此时IO中bi比较小，说明文件系统效率比较好。 
swap
si 由内存进入内存交换区数量。
so由内存交换区进入内存数量。 

IO
bi 从块设备读入数据的总量（读磁盘）（每秒kb）。
bo 块设备写入数据的总量（写磁盘）（每秒kb）
这里我们设置的bi+bo参考值为1000，如果超过1000，而且wa值较大应该考虑均衡磁盘负载，可以结合iostat输出来分析
```

### ansible

1. debug 模块

   调试模块，用于在调试中输出信息

   常用参数：

   msg: 调试输出的消息

   var: 将某个任务执行的输出作为变量传递给debug模块，debug会直接将其打印输出

   verbosity: debug 级别（默认0级，全部显示)

   ```
     - debug:
         var: mkdir_backupdir_res.changed
         verbosity: "{{verbose}}"
   ```

2. connection 

   ansible 的连接方式有paramiko, ssh, local 三种，可以指定连接方式

> Connection plugins allow Ansible to connect to the target hosts so it can execute tasks on them. Ansible ships with many connection plugins, but only one can be used per host at a time.

```
connection: local
```

3. assert                        

   Fail with custom message


## ++系统常见进程++

###systemd-udevd 

    systemd-udevd是监听内核发出的设备事件，并根据udev规则处理每个事件
    
    	--daemon 脱离控制台，并作为后台守程运行。
    
        --debug 在标准错误上打印调试信息
    
        --children-max= 限制最多同时处理多少个设备事件
    
        --exec-delay= 在运行RUN程序列表前暂停的秒数
    
        --event-timeout= 设置处理设备事件的最大允许秒数，若超时则强制终止。默认值180秒
    
            --reslove-names= early|late|never
    
            指定 systemd-udevd 应该何时解析用户与组的名称。
    
              early（默认值）表示在规则的解析阶段
    
              late 表示在每个事件发生的时候
    
              never表示从不解析，所有设备的宿主与属组都是root
    
      实例： 热插拔使用过udev服务监管实现的,(systemd-udevd)
    
    udev守护进程([systemd-udevd.service(8)](http://www.xytiao.cn/index/file/systemd-udevd.service.html#)) 直接从内核接收设备的插入、拔出、改变状态等事件， 并根据这些事件的各种属性， 到规则库中进行匹配，以确定触发事件的设备。 被匹配成功的规则有可能提供额外的设备信息，这些信息可能会被记录到udev数据库中， 也可能会被用于创建符号链接
    
    详见: [http://www.xytiao.cn/index/file/udev.html](http://www.xytiao.cn/index/file/udev.html)

### apt-daily

使用apt 出现错误:

```
E: Could not get lock /var/lib/dpkg/lock - open (11: Resource temporarily unavailable)
E: Unable to lock the administration directory (/var/lib/dpkg/), is another process using it?
```

ps  抓取发现是系统服务占用

```
ps -ef|grep apt
root      1997     1  0 17:35 ?        00:00:00 /usr/bin/python3 /usr/sbin/aptd
root      2166     1  0 17:42 ?        00:00:00 /bin/sh /usr/lib/apt/apt.systemd.daily install
root      2170  2166  0 17:42 ?        00:00:00 /bin/sh /usr/lib/apt/apt.systemd.daily lock_is_held install
```

这是因为ubuntu 引入了自动更新, 关闭它即可

```
sudo systemctl disable apt-daily.service # 使得自动更新服务不再开机启动
sudo systemctl disable apt-daily.timer   # 使得timer不再能用
```



​    

##++SYSTEMD++  

--system.unit`为任意进程创建.service服务`

写在前边

```
- 重新加载systemd配置
  systemctl daemon-reload
- 查看systemctl 执行报错
  systemctl status *.service
  journalctl -xe
- WantedBy= 会在列表单元.wants下创建一个指向该单元文件的软连接
  systemctl  enable  ss
Created symlink /etc/systemd/system/multi-	user.target.wants/ss.service → /etc/systemd/system/ss.service.
```



###单元配置

有以下类型: `.service, .socket, .device, .mount, .automount, .swap, .target, .path, .timer, .slice, .scope `

### 单元目录

systemd 将会从一组在编译时设定好的“单元目录”中加载单元文件,并按照优先级, 高优先级的会覆盖低优先级, 优先级从下列表格由下而上越来越高

如果设置了 `$SYSTEMD_UNIT_PATH` 环境变量， 那么它将会取代预设的单元目录。 如果 `$SYSTEMD_UNIT_PATH` 以 "`:`" 结尾， 那么预设的单元目录将会被添加到该变量值的末尾

- 系统单元目录

    - /etc/systemd/system/*
    - /run/systemd/system/*
    - /usr/lib/systemd/system/*

- 用户单元目录(私有用户单元目录+全局用户单元目录)

```
~/.config/systemd/user/*
/etc/systemd/user/*
$XDG_RUNTIME_DIR/systemd/user/*
/run/systemd/user/*
~/.local/share/systemd/user/*
/usr/lib/systemd/user/*
```

**表 1.  当 systemd 以系统实例(--system)运行时，加载单元的先后顺序(较前的目录优先级较高)：**

| 系统单元目录               | 描述                 |
| -------------------------- | -------------------- |
| `/etc/systemd/system`/     | 本地配置的系统单元   |
| `/run/systemd/system/`     | 运行时配置的系统单元 |
| `/usr/lib/systemd/system`/ | 软件包安装的系统单元 |

**表 2.  当 systemd 以用户实例(--user)运行时，加载单元的先后顺序(较前的目录优先级较高)：**

| 用户单元目录                     | 描述                                                         |
| -------------------------------- | ------------------------------------------------------------ |
| `$XDG_CONFIG_HOME/systemd/user`/ | 用户配置的私有用户单元(仅当 $XDG_CONFIG_HOME 已被设置时有效) |
| `~/.config/systemd/user`/        | 用户配置的私有用户单元(仅当 $XDG_CONFIG_HOME 未被设置时有效) |
| `/etc/systemd/user`/             | 本地配置的全局用户单元                                       |
| `$XDG_RUNTIME_DIR/systemd/user`/ | 运行时配置的私有用户单元(仅当 $XDG_RUNTIME_DIR 已被设置时有效) |
| `/run/systemd/user`/             | 运行时配置的全局用户单元                                     |
| `$XDG_DATA_HOME/systemd/user`/   | 软件包安装在用户家目录中的私有用户单元(仅当 $XDG_DATA_HOME 已被设置时有效) |
| `~/.local/share/systemd/user`/   | 软件包安装在用户家目录中的私有用户单元(仅当 $XDG_DATA_HOME 未被设置时有效) |
| `/usr/lib/systemd/user`/         | 软件包面向全系统安装的全局用户单元                           |

一般将配置文件放到/etc/systemd/system/下

### 单元小节

通用单元 `Uint, Install`

- 如果系统遇到无法识别的选项不会中断单元文件的加载，但是 systemd 会输出一条警告日志。 如果选项或者小节的名字以 `X-`开头， 那么 systemd 将会完全忽略它。 以 `X-` 开头的小节中的选项没必要再以 `X-` 开头， 因为整个小节都已经被忽略。 应用程序可以利用这个特性在单元文件中包含额外的信息。
- 单元文件中的布尔值可以有多种写法。 [ `1`, `yes`, `true` , `on` ] 含义相同， [ `0`, `no`, `false`, `off` ] 含义相同
- 空白行和以 # 或 ; 开头的行都会被忽略。 行尾的反斜线(\)视为续行符，并在续行时被替换为一个空格符

####[Uint] 小节

`Description=`

对单元进行简单描述的字符串。 用于UI中紧跟单元名称之后的简要描述文字

`Documentation=`

一组用空格分隔的文档URI列表， 这些文档是对此单元的详细说明。 可接受 "`http://`", "`https://`", "`file:`", "`info:`", "`man:`" 五种URI类型,可以多次使用此选项， 依次向文档列表尾部添加新文档

`Requires=`

设置此单元所必须依赖的其他单元。 当此单元被启动时，所有这里列出的其他单元也必须被启动。但并不影响这些单元的启动顺序,启动顺序需要用Befor和After来制定,建议使用Wants 代替Requires ,以提高健壮性

`Requisite=`

与 `Requires=` 类似。 不同之处在于：当单元启动时，这里列出的单元必须已经全部处于启动成功的状态， 否则，将不会启动此单元(也就是直接返回此单元启动失败的消息)， 并且同时也不会启动那些尚未成功启动的单元。

`Requisite=`

与 `Requires=` 类似。 不同之处在于：当单元启动时，这里列出的单元必须已经全部处于启动成功的状态， 否则，将不会启动此单元(也就是直接返回此单元启动失败的消息)， 并且同时也不会启动那些尚未成功启动的单元。

`BindsTo=`

与 `Requires=` 类似，但是依赖性更强： 如果这里列出的任意一个单元停止运行或者崩溃，那么也会连带导致该单元自身被停止。 这就意味着该单元可能因为 这里列出的任意一个单元的主动退出、某个设备被拔出、某个挂载点被卸载， 而被强行停止

如果将某个被依赖的单元同时放到 `After=` 与 `BindsTo=` 选项中，那么效果将会更加强烈：被依赖的单元必须严格的先于本单元启动成功之后， 本单元才能开始启动。这就意味着，不但在被依赖的单元意外停止时，该单元必须停止， 而且在被依赖的单元由于条件检查失败(例如后文的 `ConditionPathExists=`, `ConditionPathIsSymbolicLink=`, …)而被跳过时， 该单元也将无法启动。正因为如此，在很多场景下，需要同时使用 `BindsTo=` 与 `After=` 选项

`PartOf=`

----可以用于lnmp架构的php-fpm重启

与 `Requires=` 类似， 不同之处在于：仅作用于单元的停止或重启。 其含义是，当停止或重启这里列出的某个单元时， 也会同时停止或重启该单元自身。 注意，这个依赖是单向的， 该单元自身的停止或重启并不影响这里列出的单元

`Conflicts=`

指定单元之间的冲突关系。 接受一个空格分隔的单元列表，表明该单元不能与列表中的任何单元共存， 也就是说：(1)当此单元启动的时候，列表中的所有单元都将被停止； (2)当列表中的某个单元启动的时候，该单元同样也将被停止。

`Before=`, `After=`

强制指定单元之间的先后顺序，接受一个空格分隔的单元列表。 假定 `foo.service` 单元包含 `Before=bar.service` 设置， 那么当两个单元都需要启动的时候，`bar.service` 将会一直延迟到 `foo.service` 启动完毕之后再启动

`OnFailure=`

接受一个空格分隔的单元列表。 当该单元进入失败("`failed`")状态时， 将会启动列表中的单元

`PropagatesReloadTo=`, `ReloadPropagatedFrom=`

--用于lnmp 架构

接受一个空格分隔的单元列表。 `PropagatesReloadTo=` 表示 在 reload 该单元时，也同时 reload 所有列表中的单元。 `ReloadPropagatedFrom=` 表示 在 reload 列表中的某个单元时，也同时 reload 该单元

#### [Install] 小节

install 小节包含单元的启用信息, 在systemctl 的enable 和disable命令时才会使用此小节.

Alias=

启用时使用的别名，可以设为一个空格分隔的别名列表。 每个别名的后缀(也就是单元类型)都必须与该单元自身的后缀相同。 如果多次使用此选项，那么每个选项所设置的别名都会被添加到别名列表中。 在启用此单元时，**systemctl enable** 命令将会为每个别名创建一个指向该单元文件的软连接。 注意，因为 mount, slice, swap, automount 单元不支持别名，所以不要在这些类型的单元中使用此选项

```shell
cat ss.service 
[Unit]
Description=ss serice
Documentation=https://github.com/wcmbeta/GFWdata
After=network.target
[Service]
Type=forking
ExecStart=/usr/local/bin/sslocal -c /etc/ss/ss.json --log-file /var/log/ss.log -d start
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
TimeoutStopSec=5
KillMode=mixed
[Install]
WantedBy=multi-user.target
Alias=ssserver.service sslocal.service

$ systemctl  enable  ss
Created symlink /etc/systemd/system/ssserver.service → /etc/systemd/system/ss.service.
Created symlink /etc/systemd/system/sslocal.service → /etc/systemd/system/ss.service.
Created symlink /etc/systemd/system/multi-user.target.wants/ss.service → /etc/systemd/system/ss.service
```

`Also=`

设置此单元的附属单元，可以设为一个空格分隔的单元列表。 表示当使用 **systemctl enable** 启用 或 **systemctl disable** 停用 此单元时， 也同时自动的启用或停用附属单元。

DefaultInstance=`

仅对模板单元有意义， 用于指定默认的实例名称。 如果启用此单元时没有指定实例名称， 那么将使用这里设置的名称。

在 [Install] 小节的选项中，可以使用如下替换标记： %n, %N, %p, %i, %U, %u, %m, %H, %b, %v 。

**表 3. 可以用在单元文件中的替换标记**

| 符号   | 含义                                                         |
| ------ | ------------------------------------------------------------ |
| "`%n`" | 已转义的完整单元名称                                         |
| "`%N`" | 未转义的完整单元名称                                         |
| "`%p`" | 已转义的前缀名称。对于实例化的单元，就是 "`@`" 前面的部分；对于其他单元，就是去掉后缀(即类型)之后剩余的部分。 |
| "`%P`" | 未转义的前缀名称                                             |
| "`%i`" | 已转义的实例名称。对于实例化的单元，就是 "`@`" 和后缀之间的部分。 |
| "`%I`" | 未转义的实例名称                                             |
| "`%f`" | 未转义的单元文件名称(不含路径)。对于实例化的单元，就是带有 `/` 前缀的未转义实例名；对于其他单元，就是带有 `/` 前缀的未转义前缀名。 |
| "`%t`" | 运行时目录。对于系统实例来说是 `/run` ，对于用户实例来说则是 "`$XDG_RUNTIME_DIR`" 。 |
| "`%u`" | 用户名。运行 systemd 实例的用户，对于系统实例则是 "`root`"   |
| "`%U`" | 用户的UID。运行 systemd 实例的用户的UID，对于系统实例则是 "`0`" |
| "`%h`" | 用户的家目录。运行 systemd 实例的用户的家目录，对于系统实例则是 "`/root`" |
| "`%s`" | 用户的shell。运行 systemd 实例的用户的shell，对于系统实例则是 "`/bin/sh`" |
| "`%m`" | 系统的"Machine ID"字符串。参见 [machine-id(5)](http://www.jinbuguo.com/systemd/machine-id.html#) 手册 |
| "`%b`" | 系统的"Boot ID"字符串。参见 [random(4)](http://man7.org/linux/man-pages/man4/random.4.html) 手册 |
| "`%H`" | 系统的主机名(hostname)                                       |
| "`%v`" | 内核版本(**uname -r** 的输出)                                |
| "`%%`" | 百分号自身(%)。使用 "`%%`" 表示一个真正的 "`%`" 字符。       |

#### [Service]小节

每个服务单元文件都必须包含一个[Service]小节.

设置进程的启动类型， 必须设为 `simple`, `forking`, `oneshot`, `dbus`, `notify`, `idle` 之一。

如果设为 `simple` (设置了 `ExecStart=` 但未设置 `BusName=` 时的默认值)， 那么表示 `ExecStart=` 进程就是该服务的主进程。 如果此进程需要为其他进程提供服务， 那么必须在该进程启动之前先建立好通信渠道(例如套接字)， 以加快后继单元的启动速度。

如果设为 `forking` ， 那么表示 `ExecStart=` 进程将会在启动过程中使用 `fork()` 系统调用。 这是传统UNIX守护进程的经典做法。 也就是当所有的通信渠道都已建好、启动亦已成功之后， 父进程将会退出，而子进程将作为该服务的主进程继续运行。 对于此种进程， 建议同时设置 `PIDFile=` 选项， 以帮助 systemd 准确定位该服务的主进程， 进而加快后继单元的启动速度。

`oneshot` (未设置 `ExecStart=` 时的默认值) 与 `simple` 类似， 不同之处在于该进程必须在 systemd 启动后继单元之前退出。 此种类型通常需要设置 `RemainAfterExit=` 选项。

`dbus` (既设置了 `ExecStart=` 也设置了 `BusName=` 时的默认值) 与 `simple` 类似， 不同之处在于该进程需要在 D-Bus 上获得一个由 `BusName=` 指定的名称。 systemd 将会在启动后继单元之前， 首先确保该进程已经成功的获取了指定的 D-Bus 名称。 设为此类型相当于隐含的依赖于 `dbus.socket` 单元。

`notify` 与 `simple` 类似， 不同之处在于该进程将会在启动完成之后通过 [sd_notify(3)](http://www.jinbuguo.com/systemd/sd_notify.html#) 之类的接口发送一个通知消息。 systemd 将会在启动后继单元之前， 首先确保该进程已经成功的发送了这个消息。 如果设为此类型， 那么下文的 `NotifyAccess=` 将只能设为非 `none` 值。 如果 `NotifyAccess=` 未设置， 或者已经被明确设为 `none` ， 那么将会被自动强制修改为 `main` 。 注意，目前 `Type=``notify` 尚不能在 `PrivateNetwork=``yes` 的情况下正常工作。

`idle` 与 `simple` 类似， 不同之处在于该进程将会被延迟到所有活动的任务都完成之后再执行。 这样可以避免控制台上的状态信息与shell脚本的输出混杂在一起。 注意：(1) `idle` 仅可用于改善控制台输出，切勿将其用于不同单元之间的排序工具； (2)延迟最多不超过5秒，超时后将无条件的启动服务进程

`GuessMainPID=`[¶](http://www.jinbuguo.com/systemd/systemd.service.html#GuessMainPID=)

在无法明确定位该服务主进程的情况下， systemd 是否应该猜测主进程的PID(可能不正确)。 该选项仅在设置了 `Type=forking` 但未设置 `PIDFile=` 的情况下有意义。 如果PID猜测错误， 那么该服务的失败检测与自动重启功能将失效。 默认值为 `yes`

`PIDFile=`

 	-- 此文件必须存在, 如果不存在请手工创建, 不然系统调用会一直处于ppoll 阶段,导致超时无法启动

守护进程的PID文件，必须是绝对路径。 强烈建议在 `Type=``forking` 的情况下明确设置此选项。 systemd 将会在此服务启动后从此文件中读取主守护进程的PID 。 systemd 不会写入此文件， 但会在此服务停止后删除它(若存在)

`ExecStart=`

在启动该服务时需要执行的命令行(命令+参数)。

除非 `Type=oneshot` ，否则必须且只能设置一个命令行。 仅在 `Type=oneshot` 的情况下，才可以设置任意个命令行(包括零个)， 多个命令行既可以在同一个 `ExecStart=` 中设置,可以使用分号(;)将多个命令行连接起来，也可以通过设置多个 `ExecStart=` 来达到相同的效果。 如果设为一个空字符串，那么先前设置的所有命令行都将被清空。 如果不设置任何 `ExecStart=` 指令， 那么必须确保设置了 `RemainAfterExit=yes` 指令，并且至少设置一个 `ExecStop=` 指令。 同时缺少 `ExecStart=` 与 `ExecStop=` 的服务单元是非法的(也就是必须至少明确设置其中之一)。

命令行必须以一个绝对路径表示的可执行文件开始，并且其后的那些参数将依次作为"argv[1] argv[2] …"传递给被执行的进程。 可选的，可以在绝对路径前面加上各种不同的前缀表示不同的含义：

**表 1. 可执行文件前的特殊前缀**

| 前缀   | 效果                                                         |
| ------ | ------------------------------------------------------------ |
| "`@`"  | 如果在绝对路径前加上可选的 "`@`" 前缀，那么其后的那些参数将依次作为"argv[0] argv[1] argv[2] …"传递给被执行的进程(注意，argv[0] 是可执行文件本身)。 |
| "`-`"  | 如果在绝对路径前加上可选的 "`-`" 前缀，那么即使该进程以失败状态(例如非零的返回值或者出现异常)退出，也会被视为成功退出。 |
| "`+`"  | 如果在绝对路径前加上可选的 "`+`" 前缀，那么进程将拥有完全的权限(超级用户的特权)，并且 `User=`, `Group=`, `CapabilityBoundingSet=` 选项所设置的权限限制以及 `PrivateDevices=`, `PrivateTmp=` 等文件系统名字空间的配置将被该命令行启动的进程忽略(但仍然对其他 `ExecStart=`, `ExecStop=` 有效)。 |
| "`!`"  | 与 "`+`" 类似(进程仍然拥有超级用户的身份)，不同之处在于仅忽略 `User=`, `Group=`, `SupplementaryGroups=` 选项的设置，而例如名字空间之类的其他限制依然有效。注意，当与 `DynamicUser=` 一起使用时，将会在执行该命令之前先动态分配一对 user/group ，然后将身份凭证的切换操作留给进程自己去执行。 |
| "`!!`" | 与 "`!`" 极其相似，仅用于让利用 ambient capability 限制进程权限的单元兼容不支持 ambient capability 的系统(也就是不支持 `AmbientCapabilities=` 选项)。如果在不支持 ambient capability 的系统上使用此前缀，那么 `SystemCallFilter=` 与 `CapabilityBoundingSet=` 将被隐含的自动修改为允许进程自己丢弃 capability 与特权用户的身份(即使原来被配置为禁止这么做)，并且 `AmbientCapabilities=` 选项将会被忽略。此前缀在支持 ambient capability 的系统上完全没有任何效果。 |

"`@`", "`-`" 以及 "`+`"/"`!`"/"`!!`" 之一，可以按任意顺序同时混合使用。 注意，对于 "`+`", "`!`", "`!!`" 前缀来说，仅能单独使用三者之一，不可混合使用多个。 注意，这些前缀同样也可以用于 `ExecStartPre=`, `ExecStartPost=`, `ExecReload`, `ExecStop=`, `ExecStopPost=` 这些接受命令行的选项。

如果设置了多个命令行， 那么这些命令行将以其在单元文件中出现的顺序依次执行。 如果某个无 "`-`" 前缀的命令行执行失败， 那么剩余的命令行将不会被继续执行， 同时该单元将变为失败(failed)状态。

当未设置 `Type=forking` 时， 这里设置的命令行所启动的进程 将被视为该服务的主守护进程

`ExecStartPre=`, `ExecStartPost=`

设置在执行 `ExecStart=` 之前/后执行的命令行。 语法规则与 `ExecStart=` 完全相同。 如果设置了多个命令行， 那么这些命令行将以其在单元文件中出现的顺序依次执行。

如果某个无 "`-`" 前缀的命令行执行失败， 那么剩余的命令行将不会被继续执行， 同时该单元将变为失败(failed)状态。

仅在所有无 "`-`" 前缀的 `ExecStartPre=` 命令全部执行成功的前提下， 才会继续执行 `ExecStart=` 命令。

`ExecStartPost=` 命令仅在 `ExecStart=` 中的命令已经全部执行成功之后才会运行， 判断的标准基于 `Type=` 选项。 具体说来，对于 `Type=simple` 或 `Type=idle` 就是主进程已经成功启动； 对于 `Type=oneshot` 来说就是最后一个 `ExecStart=` 进程已经成功退出； 对于 `Type=forking` 来说就是初始进程已经成功退出； 对于 `Type=notify` 来说就是已经发送了 "`READY=1`" ； 对于 `Type=dbus` 来说就是已经取得了 `BusName=` 中设置的总线名称。

注意，不可将 `ExecStartPre=` 用于需要长时间执行的进程。 因为所有由 `ExecStartPre=` 派生的子进程 都会在启动 `ExecStart=` 服务进程之前被杀死。

注意，如果在服务启动完成之前，任意一个 `ExecStartPre=`, `ExecStart=`, `ExecStartPost=` 中无 "`-`" 前缀的命令执行失败或超时， 那么，`ExecStopPost=` 将会被继续执行，而 `ExecStop=` 则会被跳过。

`ExecReload=`

这是一个可选的指令， 用于设置当该服务被要求重新载入配置时所执行的命令行。 语法规则与 `ExecStart=` 完全相同。

另外，还有一个特殊的环境变量 `$MAINPID` 可用于表示主进程的PID， 例如可以这样使用：

```
/bin/kill -HUP $MAINPID
```

注意，像上例那样，通过向守护进程发送复位信号， 强制其重新加载配置文件，并不是一个好习惯。 因为这是一个异步操作， 所以不适用于需要按照特定顺序重新加载配置文件的服务。 我们强烈建议将 `ExecReload=` 设为一个 能够确保重新加载配置文件的操作同步完成的命令行。

`ExecStop=`

这是一个可选的指令， 用于设置当该服务被要求停止时所执行的命令行。 语法规则与 `ExecStart=` 完全相同。 执行完此处设置的所有命令行之后，该服务将被视为已经停止， 此时，该服务所有剩余的进程将会根据 `KillMode=` 的设置被杀死(参见 [systemd.kill(5)](http://www.jinbuguo.com/systemd/systemd.kill.html#))。 如果未设置此选项，那么当此服务被停止时， 该服务的所有进程都将会根据 `KillSignal=` 的设置被立即全部杀死。 与 `ExecReload=` 一样， 也有一个特殊的环境变量 `$MAINPID` 可用于表示主进程的PID 。

一般来说，不应该仅仅设置一个结束服务的命令而不等待其完成。 因为当此处设置的命令执行完之后， 剩余的进程会被按照 `KillMode=` 与 `KillSignal=` 的设置立即杀死， 这可能会导致数据丢失。 因此，这里设置的命令必须是同步操作，而不能是异步操作。

注意，仅在服务确实启动成功的前提下，才会执行 `ExecStop=` 中设置的命令。 如果服务从未启动或启动失败(例如，任意一个 `ExecStart=`, `ExecStartPre=`, `ExecStartPost=` 中无 "`-`" 前缀的命令执行失败或超时)， 那么 `ExecStop=` 将会被跳过。 如果想要无条件的在服务停止后执行特定的动作，那么应该使用 `ExecStopPost=`选项。

应该将此选项用于那些必须在服务干净的退出之前执行的命令。 当此选项设置的命令被执行的时候，应该假定服务正处于完全正常的运行状态，可以正常的与其通信。 如果想要无条件的在服务停止后"清理尸体"，那么应该使用 `ExecStopPost=` 选项。

`ExecStopPost=`

这是一个可选的指令， 用于设置在该服务停止之后所执行的命令行。 语法规则与 `ExecStart=` 完全相同。 注意，与 `ExecStop=` 不同，无论服务是否启动成功， 此选项中设置的命令都会在服务停止后被无条件的执行。

应该将此选项用于设置那些无论服务是否启动成功都必须在服务停止后无条件执行的清理操作。 此选项设置的命令必须能够正确处理由于服务启动失败而造成的各种残缺不全以及数据不一致的场景。 由于此选项设置的命令在执行时，整个服务的所有进程都已经全部结束，所以无法与服务进行任何通信。

注意，此处设置的所有命令在被调用之后都可以读取如下环境变量： `$SERVICE_RESULT`(服务的最终结果), `$EXIT_CODE`(服务主进程的退出码), `$EXIT_STATUS`(服务主进程的退出状态)。 详见 [systemd.exec(5)](http://www.jinbuguo.com/systemd/systemd.exec.html#) 手册。

`RestartSec=`

设置在重启服务(`Restart=`)前暂停多长时间。 默认值是100毫秒(100ms)。 如果未指定时间单位，那么将视为以秒为单位。 例如设为"20"等价于设为"20s"。

`TimeoutStartSec=`

设置该服务允许的最大启动时长。 如果守护进程未能在限定的时长内发出"启动完毕"的信号，那么该服务将被视为启动失败，并会被关闭。 如果未指定时间单位，那么将视为以秒为单位。 例如设为"20"等价于设为"20s"。 设为 "`infinity`" 则表示永不超时。 当 `Type=oneshot` 时， 默认值为 "`infinity`" (永不超时)， 否则默认值等于`DefaultTimeoutStartSec=` 的值(参见 [systemd-system.conf(5)](http://www.jinbuguo.com/systemd/systemd-system.conf.html#) 手册)。

`TimeoutStopSec=`

设置该服务允许的最大停止时长。 如果该服务未能在限定的时长内成功停止， 那么将会被强制使用 `SIGTERM` 信号关闭， 如果依然未能在相同的时长内成功停止， 那么将会被强制使用 `SIGKILL` 信号关闭(参见 [systemd.kill(5)](http://www.jinbuguo.com/systemd/systemd.kill.html#) 手册中的 `KillMode=` 选项)。 如果未指定时间单位，那么将视为以秒为单位。 例如设为"20"等价于设为"20s"。 设为 "`infinity`" 则表示永不超时。 默认值等于 `DefaultTimeoutStopSec=` 的值(参见 [systemd-system.conf(5)](http://www.jinbuguo.com/systemd/systemd-system.conf.html#) 手册)。

`TimeoutSec=`

一个同时设置 `TimeoutStartSec=` 与 `TimeoutStopSec=` 的快捷方式。

 `estart=`

当服务进程正常退出、异常退出、被杀死、超时的时候， 是否重新启动该服务。 所谓"服务进程"是指 `ExecStartPre=`, `ExecStartPost=`, `ExecStop=`, `ExecStopPost=`,`ExecReload=` 中设置的进程。 当进程是由于 systemd 的正常操作(例如 **systemctl stop|restart**)而被停止时， 该服务不会被重新启动。 所谓"超时"可以是看门狗的"keep-alive ping"超时， 也可以是 **systemctl start|reload|stop** 操作超时。

该选项的值可以取 `no`, `always`, `on-success`, `on-failure`, `on-abnormal`, `on-watchdog`, `on-abort` 之一。 `no`(默认值) 表示不会被重启。 `always` 表示会被无条件的重启。`on-success` 表示仅在服务进程正常退出时重启， 所谓"正常退出"是指： 退出码为"0"， 或者进程收到 `SIGHUP`, `SIGINT`, `SIGTERM`, `SIGPIPE` 信号之一， 并且退出码符合`SuccessExitStatus=` 的设置。 `on-failure` 表示仅在服务进程异常退出时重启， 所谓"异常退出"是指： 退出码不为"0"， 或者进程被强制杀死(包括 "core dump"以及收到`SIGHUP`, `SIGINT`, `SIGTERM`, `SIGPIPE` 之外的其他信号)， 或者进程由于看门狗或者 systemd 的操作超时而被杀死。

**表 2. Restart= 的设置分别对应于哪些退出原因**

| 退出原因(↓) \| Restart= (→) | `no` | `always` | `on-success` | `on-failure` | `on-abnormal` | `on-abort` | `on-watchdog` |
| --------------------------- | ---- | -------- | ------------ | ------------ | ------------- | ---------- | ------------- |
| 正常退出                    |      | X        | X            |              |               |            |               |
| 退出码不为"0"               |      | X        |              | X            |               |            |               |
| 进程被强制杀死              |      | X        |              | X            | X             | X          |               |
| systemd 操作超时            |      | X        |              | X            | X             |            |               |
| 看门狗超时                  |      | X        |              | X            | X             |            | X             |

 

注意如下例外情况(详见下文)： (1) `RestartPreventExitStatus=` 中列出的退出码或信号永远不会导致该服务被重启。 (2) 被 **systemctl stop** 命令或等价的操作停止的服务永远不会被重启。 (3) `RestartForceExitStatus=` 中列出的退出码或信号将会无条件的导致该服务被重启。

注意，服务的重启频率仍然会受到由 `StartLimitIntervalSec=` 与 `StartLimitBurst=` 定义的启动频率的制约。详见 [systemd.unit(5)](http://www.jinbuguo.com/systemd/systemd.unit.html#) 手册。

对于需要长期持续运行的守护进程， 推荐设为 `on-failure` 以增强可用性。 对于自身可以自主选择何时退出的服务， 推荐设为 `on-abnormal`



### Template

使用模板, 一个模板单元文件可以创建多个实例化的单元文件, 从而简化系统配置

模板单元文件的文件名中包含一个@符号, @位于单元基本文件名和扩展名之间如`example@.service`

当从模板单元文件创建实例单元文件时, 在@符号和单元扩展名之前加上实例名如: `example@instance1.service`

表明实例单元文件`example@instance1.service`实例化自模板文件`example@.service`,其实例名为`instance1`	

实例单元文件一般是模板单元文件的一个符号链接，符号链接命中包含实例名，systemd就会传递实例名给模板单元文件

在相应的taget中创建实例单元文件符号链接之后，需要运行一下命令将其装载：``$ `sudo` `systemctl daemon-reload`

占位符

| **占位符** | **作用**                                                     |
| ---------- | ------------------------------------------------------------ |
| **%n**     | 完整的 Unit 文件名字，包括 .service 后缀名                   |
| **%m**     | 实际运行的节点的 Machine ID，适合用来做Etcd路径的一部分，例如 /machines/%m/units |
| **%b**     | 作用有点像 Machine ID，但这个值每次节点重启都会改变，称为 Boot ID |
| **%H**     | 实际运行节点的主机名                                         |
| **%p**     | Unit 文件名中在 @ 符号之前的部分，不包括 @ 符号              |
| **%i**     | Unit 文件名中在 @ 符号之后的部分，不包括 @ 符号和 .service 后缀名 |

示例:

```
[Unit]
Description=My Advanced Service Template
After=etcd.servicedocker.service
[Service]
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill apache%i
ExecStartPre=-/usr/bin/docker rm apache%i
ExecStartPre=/usr/bin/docker pull coreos/apache
ExecStart=/usr/bin/docker run --name apache%i -p %i:80 coreos/apache /usr/sbin/apache2ctl -D FOREGROUND
ExecStartPost=/usr/bin/etcdctl set /domains/example.com/%H:%i running
ExecStop=/usr/bin/docker stop apache1
ExecStopPost=/usr/bin/etcdctl rm /domains/example.com/%H:%i
[Install]
WantedBy=multi-user.target
```

启动命令: systemctl start docker@8080.service

Systemd 首先会在其特定的目录下寻找名为  apache@8080.service的文件，如果没有找到，而文件名中包含@字符，它就会尝试去掉后缀参数匹配模板文件。例如没有找到  apache@8080.service，那么Systemd会找到apache@.service，并将它通过模板文件中实例化





## ++K8S++

### Minikube 单节点

单节点在`https://packages.cloud.google.` 下, 无法直接连接

一般使用阿里云的源

Minikube  命令行客户端 kubectl

1. 安装kubectl (必须科学上网)
2. 安装Minikube , 使用阿里云的节点, 在下载Minikube ISO 比较快

```
curl -Lo minikube http://kubernetes.oss-cn-hangzhou.aliyuncs.com/minikube/releases/v0.28.1/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
```

3. 启动minikube , 需要下载, 

4. 因为minikube创建K8S虚机是通过Virtualbox来做的, 也可以使用kvm 来启动`minikube start --vm-driver=kvm2`

   下载virtualbox 驱动`https://www.virtualbox.org/wiki/Downloads`

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```



















### K8S集群

本次实验采用三个节点

分别: 

| version      | IP              | Role   | hostname |
| ------------ | --------------- | ------ | -------- |
| ubuntu 18.04 | 192.168.122.1   | master | server   |
| ubuntu16.04  | 192.168.122.229 | worker | node1    |
| ubuntu16.04  | 192.168.122.89  | worker | node2    |

<u>基础配置</u>

1. 安装docker

```shell
- 卸载旧版本
apt-get remove docker docker-engine docker.io
- 更新apt-get 源
add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
- 安装apt 的https支持包并添加gpg秘钥
apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
- 更新源
apt update
- 安装docker-ce
apt-get install -y docker-ce
or 
#######################
- 安装指定版本列表
apt-cache madison docker-ce
- 制定版本安装
apt-get install -y docker-ce=17.09.1~ce-0~ubuntu

######################
- 接收所有的IP数据包转发
vi /lib/systemd/system/docker.service
找到ExecStart=xxx，在这行上面加入一行，内容如下：(k8s的网络需要)
ExecStartPost=/sbin/iptables -I FORWARD -s 0.0.0.0/0 -j ACCEPT
- 重新加载systemd,启动服务
systemctl daemon_reload
systemctl start docker 
- 查看日志是否报错
journactl -f -u docker
-f 持续输出日志  -u 跟踪服务单元

```

2. 关闭防火墙并允许路由转发, 不对bridge 的数据进行处理

```shell
#写入配置文件
$ cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
#生效配置文件
sysctl -p /etc/sysctl.d/k8s.conf
```

3. 在各个节点修改hosts文件, 做好免密工作

4. 下载k8s的bin包 [https://pan.baidu.com/s/1bMnqWY]( bin包)

5. 下载配置文件

   ```
   #到home目录下载项目
   $ cd
   $ git clone https://github.com/liuyi01/kubernetes-starter.git
   #看看git内容
   $ cd ~/kubernetes-starter && ls
   ```

6. 文件说明

   - **gen-config.sh**

   > shell脚本，用来根据每个同学自己的集群环境(ip，hostname等)，根据下面的模板，生成适合大家各自环境的配置文件。生成的文件会放到target文件夹下。

   - **kubernetes-simple**

   > 简易版kubernetes配置模板（剥离了认证授权）。 适合刚接触kubernetes的同学，首先会让大家在和kubernetes初次见面不会印象太差（太复杂啦~~），再有就是让大家更容易抓住kubernetes的核心部分，把注意力集中到核心组件及组件的联系，从整体上把握kubernetes的运行机制。

   - **kubernetes-with-ca**

   > 在simple基础上增加认证授权部分。大家可以自行对比生成的配置文件，看看跟simple版的差异，更容易理解认证授权的（认证授权也是kubernetes学习曲线较高的重要原因）

   - **service-config**

   > 这个先不用关注，它是我们曾经开发的那些微服务配置。 等我们熟悉了kubernetes后，实践用的，通过这些配置，把我们的微服务都运行到kubernetes集群中。

7. 生成配置

   这里会根据大家各自的环境生成kubernetes部署过程需要的配置文件。 在每个节点上都生成一遍，把所有配置都生成好，后面会根据节点类型去使用相关的配置。

   ```
   #cd到之前下载的git代码目录
   $ cd ~/kubernetes-starter
   #编辑属性配置（根据文件注释中的说明填写好每个key-value）
   $ vi config.properties
   #生成配置文件，确保执行过程没有异常信息
   $ ./gen-config.sh simple
   #查看生成的配置文件，确保脚本执行成功
   $ find target/ -type f
   target/all-node/kube-calico.service
   target/master-node/kube-controller-manager.service
   target/master-node/kube-apiserver.service
   target/master-node/etcd.service
   target/master-node/kube-scheduler.service
   target/worker-node/kube-proxy.kubeconfig
   target/worker-node/kubelet.service
   target/worker-node/10-calico.conf
   target/worker-node/kubelet.kubeconfig
   target/worker-node/kube-proxy.service
   target/services/kube-dns.yaml
   ```

   <u>基础集群部署</u>

   在每个服务启动后都要跟踪一下启动状态, 避免因为某个服务没有正常启动导致后期拍错困难

   1. 部署ETCD(主节点)

   kubernetes需要存储很多东西，像它本身的节点信息，组件信息，还有通过kubernetes运行的pod，deployment，service等等。都需要持久化。etcd就是它的数据中心。生产环境中为了保证数据中心的高可用和数据的一致性，一般会部署最少三个节点。本次仅有一个节点

   将kubernetes-bins 移动到用户家目录, 这样就不用添加PATH的环境变量,可以直接使用

   ```
   #把服务配置文件copy到系统服务目录
   $ cp ~/kubernetes-starter/target/master-node/etcd.service /lib/systemd/system/
   #enable服务
   $ systemctl enable etcd.service
   #创建工作目录(保存数据的地方)
   $ mkdir -p /var/lib/etcd
   # 启动服务
   $ service etcd start
   # 查看服务日志，看是否有错误信息，确保服务正常
   $ journalctl -f -u etcd.service
   ```

   2. 部署APIServer(主节点)

   kube-apiserver是Kubernetes最重要的核心组件之一，主要提供以下的功能

   - 提供集群管理的REST API接口，包括认证授权（我们现在没有用到）数据校验以及集群状态变更等
   - 提供其他模块之间的数据交互和通信的枢纽（其他模块通过API Server查询或修改数据，只有API Server才直接操作etcd）

   > 生产环境为了保证apiserver的高可用一般会部署2+个节点，在上层做一个lb做负载均衡，比如haproxy。由于单节点和多节点在apiserver这一层说来没什么区别，所以我们学习部署一个节点就足够啦

   同理, 将kube-apiserver.service 拷贝到/lib/systemd/system 下, 开机启动,启动服务,跟踪一下服务单元日志

   3. 部署ControllerManager(主节点)

      Controller Manager由kube-controller-manager和cloud-controller-manager组成，是Kubernetes的大脑，它通过apiserver监控整个集群的状态，并确保集群处于预期的工作状态。 kube-controller-manager由一系列的控制器组成，像Replication Controller控制副本，Node Controller节点控制，Deployment Controller管理deployment等等 cloud-controller-manager在Kubernetes启用Cloud Provider的时候才需要，用来配合云服务提供商的控制

      > controller-manager、scheduler和apiserver 三者的功能紧密相关，一般运行在同一个机器上，我们可以把它们当做一个整体来看，所以保证了apiserver的高可用即是保证了三个模块的高可用。也可以同时启动多个controller-manager进程，但只有一个会被选举为leader提供服务。

      将kube-controller-master.service 拷贝到目录,启动服务,跟踪日志检查

   4. 部署Scheduler(主节点)

      kube-scheduler负责分配调度Pod到集群内的节点上，它监听kube-apiserver，查询还未分配Node的Pod，然后根据调度策略为这些Pod分配节点。我们前面讲到的kubernetes的各种调度策略就是它实现的。

      部署同理将kube-scheduler.service 拷贝到制定目录,跟踪该日志

   5. 部署CalicoNode(所有节点)

      Calico实现了CNI接口，是kubernetes网络方案的一种选择，它一个纯三层的数据中心网络方案（不需要Overlay），并且与OpenStack、Kubernetes、AWS、GCE等IaaS和容器平台都有良好的集成。 Calico在每一个计算节点利用Linux Kernel实现了一个高效的vRouter来负责数据转发，而每个vRouter通过BGP协议负责把自己上运行的workload的路由信息像整个Calico网络内传播——小规模部署可以直接互联，大规模下可通过指定的BGP route reflector来完成。 这样保证最终所有的workload之间的数据流量都是通过IP路由的方式完成互联的。

      拷贝系统服务到指定目录

      ```
      $ cp target/all-node/kube-calico.service /lib/systemd/system/
      $ systemctl enable kube-calico.service
      $ service kube-calico start
      $ journalctl -f -u kube-calico
      ```

      验证calico可用性

      ```
      1. docker ps 
      CONTAINER ID        IMAGE                                                        COMMAND             CREATED             STATUS              PORTS               NAMES
      ed0d292a981d        registry.cn-hangzhou.aliyuncs.com/imooc/calico-node:v2.6.2   "start_runit"       15 seconds ago      Up 9 seconds                            calico-node
      2. 查看节点运行情况
      calicoctl node status
      Calico process is running.
      
      IPv4 BGP status
      No IPv4 peers found.
      
      IPv6 BGP status
      No IPv6 peers found.
      几个节点都起来后
      ./calicoctl  node status
      Calico process is running.
      
      IPv4 BGP status
      +-----------------+-------------------+-------+----------+-------------+
      |  PEER ADDRESS   |     PEER TYPE     | STATE |  SINCE   |    INFO     |
      +-----------------+-------------------+-------+----------+-------------+
      | 192.168.1.111   | node-to-node mesh | up    | 10:14:54 | Established |
      | 192.168.122.229 | node-to-node mesh | up    | 10:16:10 | Established |
      +-----------------+-------------------+-------+----------+-------------+
      
      3. 查看端口BGP 协议是通过TCP 连接来建立邻居的, 因此可以使用netstat 命令来验证BGP Peer
       netstat -natp|grep ESTABLISHED|grep 179
       tcp        0      0 192.168.122.89:179      192.168.1.111:37459     ESTABLISHED 16574/bird      
      tcp        0      0 192.168.122.89:34249    192.168.122.229:179     ESTABLISHED 16574/bird
      4. 查看集群ippool 情况(主节点上)
      calicoctl get ipPool -o yaml
      ./calicoctl get ipPool -o yaml
      - apiVersion: v1
        kind: ipPool
        metadata:
          cidr: 172.20.0.0/16
        spec:
      	nat-outgoing: true
      ```

      6. 配置kubectl (任意节点)

         kubectl是Kubernetes的命令行工具，是Kubernetes用户和管理员必备的管理工具。 kubectl提供了大量的子命令，方便管理Kubernetes集群中的各种功能。

         初始化:

         使用kubectl 的第一步是配置kubenetes集群及认证方式,包括:

         - cluster 信息: api-server 地址
         - 用户信息: 用户名, 密码或秘钥
         - context: cluster, 用户信息及namespace 的组合

         目前没有安全相关配置, 仅需配置api-server 及上下文

         ```
         #指定apiserver地址（ip替换为你自己的api-server地址）
         sudo ./kubectl config set-cluster kubernetes  --server=http://192.168.122.1:8080
         Cluster "kubernetes" set
         #指定设置上下文，指定cluster
         kubectl config set-context kubernetes --cluster=kubernetes
         Context "kubernetes" created.
         #选择默认的上下文
         kubectl config use-context kubernetes
         Switched to context "kubernetes".
         通过上面的设置最终目的是生成了一个配置文件：~/.kube/config，当然你也可以手写或复制一个文件放在那，就不需要上面的命令了。
         ```

         7. 配置kubelet(工作节点)

            每个工作节点上都运行一个kubelet服务进程，默认监听10250端口，接收并执行master发来的指令，管理Pod及Pod中的容器。每个kubelet进程会在API Server上注册节点自身信息，定期向master节点汇报节点的资源使用情况，并通过cAdvisor监控节点和容器的资源。

            部署:

            **通过系统服务方式部署，但步骤会多一些，具体如下：**

            ```
            #确保相关目录存在
            $ mkdir -p /var/lib/kubelet
            $ mkdir -p /etc/kubernetes
            $ mkdir -p /etc/cni/net.d
            
            #复制kubelet服务配置文件
            $ cp target/worker-node/kubelet.service /lib/systemd/system/
            #复制kubelet依赖的配置文件
            $ cp target/worker-node/kubelet.kubeconfig /etc/kubernetes/
            #复制kubelet用到的cni插件配置文件
            $ cp target/worker-node/10-calico.conf /etc/cni/net.d/
            
            $ systemctl enable kubelet.service
            $ service kubelet start
            $ journalctl -f -u kubelet
            ```









## ++Openstack Rocky 版本安装++

### - 数据库

	update user set password=password("000") where user='root';

- bind-address

```
[mysqld]
bind-address = xx.xx.xxx.xx
是MYSQL用来监听某个单独的TCP/IP连接,只能绑定一个IP地址,被绑定的IP地址可以映射多个网络接口. 
可以是IPv4,IPv6或是主机名,但需要在MYSQL启动的时候指定(主机名在服务启动的时候解析成IP地址进行绑定).
默认是"*"
```

参数	应用场景

接收所有的IPv4 或 IPv6 连接请求
0.0.0.0	接受所有的IPv4地址
::	接受所有的IPv4 或 IPv6 地址
IPv4-mapped	接受所有的IPv4地址或IPv4邦定格式的地址（例 ::ffff:127.0.0.1）
IPv4（IPv6）	只接受对应的IPv4（IPv6）地址

```shell
innodb_file_per_table = on
innodb存储引擎可以将所有数据存放于ibdata*的共享表空间，也可以将每张表存放于独立的.ibd表空间
@https://blog.csdn.net/jesseyoung/article/details/42236615
```

### - keystone

```shelll
# openstack user create --domain default --password-prompt glance
The request you have made requires authentication. (HTTP 401) (Request-ID: req-55d15577-9d5e-4db5-b858-acdbb0b68fc1)
tail -20f /var/log/keystone/keystone.log
2018-10-22 00:57:45.265 12444 WARNING keystone.common.wsgi [req-f8d3acb6-f8ef-4ae8-bbf5-99174e43378e 5fc122903a4049fc82ab2475453eca1a 61a8cdde6cc64982aa272a0dfcd4457b - default default] You are not authorized to perform the requested action: identity:create_user.: ForbiddenAction: You are not authorized to perform the requested action: identity:create_user.
2018-10-22 13:23:47.022 1290 INFO keystone.common.wsgi [req-55d15577-9d5e-4db5-b858-acdbb0b68fc1 - - - - -] POST http://controller:5000/v3/auth/tokens
2018-10-22 13:23:48.689 1290 WARNING keystone.common.wsgi [req-55d15577-9d5e-4db5-b858-acdbb0b68fc1 - - - - -] Authorization failed. The request you have made requires authentication. from 192.168.1.220: Unauthorized: The request you have made requires authentication.
```

错误原因：

在创建完admin 用户脚本后， 修改了admin-openrc, 将用户修改到了myproject中，导致鉴权失败，将project_name, username password 修改回来后正常创建

```
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin_pass
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=
```



```
grant all privileges on keystone.* to 'keystone'@'%' identified by 'keystone_dbpass';
```

```
keystone-manage bootstrap --bootstrap-password admin_pass \
  --bootstrap-admin-url http://controller:5000/v3/ \
  --bootstrap-internal-url http://controller:5000/v3/ \
  --bootstrap-public-url http://controller:5000/v3/ \
  --bootstrap-region-id RegionOne
```

```
 export OS_USERNAME=admin
 export OS_PASSWORD=admin_pass
 export OS_PROJECT_NAME=admin
 export OS_USER_DOMAIN_NAME=Default
 export OS_PROJECT_DOMAIN_NAME=Default
 export OS_AUTH_URL=http://controller:5000/v3
 export OS_IDENTITY_API_VERSION=3
```

```
# echo $OS_AUTH_URL
http://controller:5000/v3
[root@vm1 ~]# echo $OS_PASSWORD
admin_pass
```

```
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
  IDENTIFIED BY 'glance_dbpass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
  IDENTIFIED BY 'glance_dbpass';
 
 
```

### -nova

```
	GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' \
  IDENTIFIED BY 'nova_dbpass';
  GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' \
  IDENTIFIED BY 'placement_dbpass';
  GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' \
  IDENTIFIED BY 'placement_dbpass';
  
  
  
```

填充nova-api 和placement数据库报错：

```shell
CantStartEngineError: No sql_connection parameter is established
```

原因是缺少数据库连接参数

解决办法：在出现问题的节点（一般是计算节点）添加下面的配置项目:

```
[database]
connection = mysql+pymysql://nova:nova_dbpass@controller/nova_cell0?charset=utf8
[api_database]
connection = mysql+pymysql://nova:nova_dbpass@controller/nova_api?charset=utf8
```

```
systemctl start openstack-nova-compute.service
长时间无响应且日志无输出
原因： /etc/hosts未配置controll解析
```

```

```





### - ceph 

  Ceph 集群的逻辑结构由Pool和PG(Placement Group) 来定义

安装报错：

```
[admin-node][WARNIN] ensuring that /etc/yum.repos.d/ceph.repo contains a high priority
[ceph_deploy][ERROR ] RuntimeError: NoSectionError: No section: 'ceph'
这个是一个bug
解决方案为：
sudo mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo
```

```
http://mirror.centos.org/centos-7/7/cloud/x86_64/openstack-rocky/repodata/6f7af7f58a1f1593ee09eeafc5452023f58c34bf23ed68cad3bf181ee28455c1-primary.sqlite.bz2
http://mirror.centos.org/centos-7/7/cloud/x86_64/openstack-rocky/repodata/6f7af7f58a1f1593ee09eeafc5452023f58c34bf23ed68cad3bf181ee28455c1-primary.sqlite.bz
```

```
rpm -qa |grep libcephf|xargs rpm -evh  --nodeps 
rpm -qa |grep librados2 |xargs rpm -evh  --nodeps
rpm -qa |grep python-rbd |xargs rpm -evh
rpm -qa |grep python-rados |xargs rpm -evh --nodeps
rpm -qa |grep librgw2  |xargs rpm -vhe --nodeps
rpm -qa |grep librbd1 |xargs rpm -evh  --nodeps
 rpm -qa |grep python-cephfs |xargs rpm  -evh 
yum-config-manager --add-repo http://download.ceph.com/rpm-luminous/el7/x86_64/
mv download.ceph.com_rpm-luminous_el7_x86_64_.repo  ceph.repo
export CEPH_DEPLOY_REPO_URL=http://download.ceph.com/rpm-luminous/el7/x86_64/
[ceph@node4 ~]$ export CEPH_DEPLOY_GPG_URL=http://download.ceph.com/keys/release.asc
```



 Ceph 集群

### - rabbitmq

rabbitmqctl  add_user openstack rabbit_pass

```shell
$sudo rabbitmqctl  set_permissions -p /vhost1  user_admin '.*' '.*' '.*'
该命令使用户user_admin具有/vhost1这个virtual host中所有资源的配置、写、读权限以便管理其中的资源
# rabbitmqctl set_permissions openstack ".*" ".*" ".*"
Setting permissions for user "openstack" in vhost "/" ...
```

### - neutron

```
2018-10-22 17:27:40.409 6131 ERROR neutron.plugins.ml2.managers [-] No type driver for tenant network_type: local. Service terminated!
原因：
解决办法：

```





















## ++SHELL++

### Array

1. 获取数组长度

   ```shell
   a=(0 1 2 3)
   echo ${#a[@]}
   4
   ```

2. 获取数组的元素内容

   ```
   echo ${a[*]}
   ```

3. 获取数组的索引列表

   ```
   echo ${!a[@]}
   0 1 2 3
   ```

4. 获取数组某个索引位置的元素

   ```
   echo ${a[i]}
   ```

5. 获取数组中某个索引位置元素的长度

   ```
   echo ${#a[i]}
   ```

| 命令     | 解释                              | 结果      |
| -------- | --------------------------------- | --------- |
| ${A[@]}  | 返回数组全部元素                  | a b c def |
| ${A[*]}  | 同上                              | a b c def |
| ${A[0]}  | 返回数组第一个元素                | a         |
| ${#A[@]} | 返回数组元素总个数                | 4         |
| ${#A[*]} | 同上                              | 4         |
| ${#A[3]} | 返回第四个元素的长度，即def的长度 | 3         |
| A[3]=xzy | 则是将第四个组数重新定义为 xyz    |           |

### $(( ))

$(()) 与整数运算

在 $(( )) 中的变量名称,可于其前面加 $ 符号来替换,也可以不用

```
[root@localhost ~]# echo $((2*3))
6
[root@localhost ~]# a=5;b=7;c=2
[root@localhost ~]# echo $((a+b*c))
19
[root@localhost ~]# echo $(($a+$b*$c))
19
```

进制转换

$(( ))可以将其他进制转成十进制数显示出来。用法如下：echo $((N#xx))其中，N为进制，xx为该进制下某个数值，命令执行后可以得到该进制数转成十进制后的值

```
[root@localhost ~]# echo $((2#110))
6
[root@localhost ~]# echo $((16#2a))
42
[root@localhost ~]# echo $((8#11))
9
```

重定义变量值

```
[root@localhost ~]# a=5;b=7
[root@localhost ~]# ((a++))
[root@localhost ~]# echo $a
6
[root@localhost ~]# ((a--));echo $a
5
[root@localhost ~]# ((a<b));echo $?
0
[root@localhost ~]# ((a>b));echo $?
1
```

### Variable

取路径，文件名，后缀

```
先赋值一个变量为一个路径，如下：
file=/dir1/dir2/dir3/my.file.txt

命令    解释    结果
${file#*/}    拿掉第一条 / 及其左边的字符串    dir1/dir2/dir3/my.file.txt
[root@localhost ~]# echo ${file#*/}
dir1/dir2/dir3/my.file.txt

${file##*/}    拿掉最后一条 / 及其左边的字符串    my.file.txt
[root@localhost ~]# echo ${file##*/}
my.file.txt

${file#*.}    拿掉第一个 . 及其左边的字符串    file.txt
[root@localhost ~]# echo ${file#*.}
file.txt

${file##*.}    拿掉最后一个 . 及其左边的字符串    txt
[root@localhost ~]# echo ${file##*.}
txt

${file%/*}    拿掉最后一条 / 及其右边的字符串    /dir1/dir2/dir3
[root@localhost ~]# echo ${file%/*}
/dir1/dir2/dir3

${file%%/*}    拿掉第一条 / 及其右边的字符串    (空值)
[root@localhost ~]# echo ${file%%/*}
(空值)

${file%.*}    拿掉最后一个 . 及其右边的字符串    /dir1/dir2/dir3/my.file
[root@localhost ~]# echo ${file%.*}
/dir1/dir2/dir3/my.file

${file%%.*}    拿掉第一个 . 及其右边的字符串    /dir1/dir2/dir3/my￼
[root@localhost ~]# echo ${file%%.*}
/dir1/dir2/dir3/my
记忆方法如下：

# 是去掉左边(在键盘上 # 在 $ 之左边)
% 是去掉右边(在键盘上 % 在 $ 之右边)
单一符号是最小匹配;两个符号是最大匹配
*是用来匹配不要的字符，也就是想要去掉的那部分
还有指定字符分隔号，与*配合，决定取哪部分
```

截取字符串段

```
1. 获取一行内容
line="AA#BB"
${line:0:1} 表示取这一行索引从0到1 的字符串
${0:0:1}  $0表示脚本名字, 0:1 表示取脚本的第一个字符
${file:0:5}            　　　提取最左边的 5 个字节    　　　　　　　　　　　　/dir1
${file:5:5}            　　　提取第 5 个字节右边的连续 5 个字节    　　　　　/dir2
${file/dir/path}            将第一个 dir 提换为 path  /path1/dir2/dir3/my.file.txt
${file//dir/path}    　　　　将全部 dir 提换为 path    /path1/path2/path3/my.file.txt
${#file}    　　　　　　　　　 获取变量长度 
```

根据状态为变量赋值

| 命令                 | 解释                                                  | 备注                 |
| -------------------- | ----------------------------------------------------- | -------------------- |
| ${file-my.file.txt}  | 若 $file 没设定,则使用 my.file.txt 作传回值           | 空值及非空值不作处理 |
| ${file:-my.file.txt} | 若 $file 没有设定或为空值,则使用 my.file.txt 作传回值 | 非空值时不作处理     |
| ${file+my.file.txt}  | 若$file 设为空值或非空值,均使用my.file.txt作传回值    | 没设定时不作处理     |
| ${file:+my.file.txt} | 若 $file 为非空值,则使用 my.file.txt 作传回值         | 没设定及空值不作处理 |
| ${file=txt}          | 若 $file 没设定,则回传 txt ,并将 $file 赋值为 txt     | 空值及非空值不作处理 |
| ${file:=txt}         | 若 $file 没设定或空值,则回传 txt ,将 $file 赋值为txt  | 非空值时不作处理     |
| ${file?my.file.txt}  | 若 $file 没设定,则将 my.file.txt 输出至 STDERR        | 空值及非空值不作处理 |
| ${file:?my.file.txt} | 若 $file没设定或空值,则将my.file.txt输出至STDERR      | 非空值时不作处理     |

以上的理解在于, 你一定要分清楚 unset 与 null 及 non-null 这三种赋值状态. 一般而言, : 与 null 有关, 若不带 : 的话, null 不受影响, 若带 : 则连 null 也受影响.

命令替换

```
在bash中，$( )与` `（反引号）都是用来作命令替换的。
命令替换与变量替换差不多，都是用来重组命令行的，先完成引号里的命令行，然后将其结果替换出来，再重组成新的命令行
#  echo Linux `echo Shell `echo today is `date "+%Y-%m-%d"```
Linux Shellecho today is 2017-11-07     #过多使用``会有问题
# echo Linux `echo Shell $(echo today is $(date "+%Y-%m-%d"))`
Linux Shell today is 2017-11-07    ``和$()混合使用
echo Linux $(echo Shell $(echo today is $(date "+%Y-%m-%d")))
Linux Shell today is 2017-11-07    #多个$()同时使用也不会有问题
```

变量替换 ${}

```
一般情况下，$var与${var}是没有区别的，但是用${ }会比较精确的界定变量名称的范围
```



### Bash

1. 声明变量

   [ https://blog.csdn.net/tenfyguo/article/details/7473706]( https://blog.csdn.net/tenfyguo/article/details/7473706)

   ```
   declare 命令时bash 的一个內建命令,可以用来声明变量属性
   常用: 
   1. 显示所有变量的值
   declare -p
   2. 显示指定变量的值
   declare -p var
   3. 声明变量并赋值
   declare var=value
   4. 声明变量类型为整形   ---可以直接对表达式求值, 此处只能是整数, 如果求值失败,或者不是整数, 就设置为0
   declare -i var
   5. 声明变量为只读, 不允许修改和删除
   declare -r var
   6. 声明变量为数组
   declare -a var 
   ```

### shell 脚本颜色

输出特效格式控制：
\033[0m  关闭所有属性  
\033[1m   设置高亮度  
\03[4m   下划线  
\033[5m   闪烁  
\033[7m   反显  
\033[8m   消隐  
\033[30m   --   \033[37m   设置前景色  
\033[40m   --   \033[47m   设置背景色



光标位置等的格式控制：
\033[nA  光标上移n行  
\03[nB   光标下移n行  
\033[nC   光标右移n行  
\033[nD   光标左移n行  
\033[y;xH设置光标位置  
\033[2J   清屏  
\033[K   清除从光标到行尾的内容  
\033[s   保存光标位置  
\033[u   恢复光标位置  
\033[?25l   隐藏光标  

\33[?25h   显示光标

整理：

​    编码 颜色/动作

　　0   重新设置属性到缺省设置

　　1   设置粗体

　　2   设置一半亮度(模拟彩色显示器的颜色)

　　4   设置下划线(模拟彩色显示器的颜色)

　　5   设置闪烁

　　7   设置反向图象

　　22 设置一般密度

　　24 关闭下划线

　　25 关闭闪烁

　　27 关闭反向图象

　　30 设置黑色前景

　　31 设置红色前景

　　32 设置绿色前景

　　33 设置棕色前景

　　34 设置蓝色前景

　　35 设置紫色前景

　　36 设置青色前景

　　37 设置白色前景

　　38 在缺省的前景颜色上设置下划线

　　39 在缺省的前景颜色上关闭下划线

　　40 设置黑色背景

　　41 设置红色背景

　　42 设置绿色背景

　　43 设置棕色背景

　　44 设置蓝色背景

　　45 设置紫色背景

　　46 设置青色背景

　　47 设置白色背景

　　49 设置缺省黑色背景

特效可以叠加，需要使用“;”隔开，例如：闪烁+下划线+白底色+黑字为   \033[5;4;47;30m闪烁+下划线+白底色+黑字为\033[0m

下面是一段小例子

```shell
#!/bin/bash
#
#下面是字体输出颜色及终端格式控制
#字体色范围：30-37
echo -e "\033[30m 黑色字 \033[0m"
echo -e "\033[31m 红色字 \033[0m"
echo -e "\033[32m 绿色字 \033[0m"
echo -e "\033[33m 黄色字 \033[0m"
echo -e "\033[34m 蓝色字 \033[0m"
echo -e "\033[35m 紫色字 \033[0m"
echo -e "\033[36m 天蓝字 \033[0m"
echo -e "\033[37m 白色字 \033[0m"
#字背景颜色范围：40-47
echo -e "\033[40;37m 黑底白字 \033[0m"
echo -e "\033[41;30m 红底黑字 \033[0m"
echo -e "\033[42;34m 绿底蓝字 \033[0m"
echo -e "\033[43;34m 黄底蓝字 \033[0m"
echo -e "\033[44;30m 蓝底黑字 \033[0m"
echo -e "\033[45;30m 紫底黑字 \033[0m"
echo -e "\033[46;30m 天蓝底黑字 \033[0m"
echo -e "\033[47;34m 白底蓝字 \033[0m"
 
#控制选项说明
#\033[0m 关闭所有属性
#\033[1m 设置高亮度
#\033[4m 下划线
echo -e "\033[4;31m 下划线红字 \033[0m"
#闪烁
echo -e "\033[5;34m 红字在闪烁 \033[0m"
#反影
echo -e "\033[8m 消隐 \033[0m "
 
#\033[30m-\033[37m 设置前景色
#\033[40m-\033[47m 设置背景色
#\033[nA光标上移n行
#\033[nB光标下移n行
echo -e "\033[4A 光标上移4行 \033[0m"
#\033[nC光标右移n行
#\033[nD光标左移n行
#\033[y;xH设置光标位置
#\033[2J清屏
#\033[K清除从光标到行尾的内容
echo -e "\033[K 清除光标到行尾的内容 \033[0m"
#\033[s 保存光标位置
#\033[u 恢复光标位置
#\033[?25| 隐藏光标
#\033[?25h 显示光标
echo -e "\033[?25l 隐藏光标 \033[0m"
echo -e "\033[?25h 显示光标 \033[0m"

```



| 参数处理 | 说明                                                         |
| -------- | ------------------------------------------------------------ |
| $#       | 传递到脚本的参数个数                                         |
| $*       | 以一个单字符串显示所有向脚本传递的参数。 如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。 |
| $$       | 脚本运行的当前进程ID号                                       |
| $!       | 后台运行的最后一个进程的ID号                                 |
| $@       | 与$*相同，但是使用时加引号，并在引号中返回每个参数。 如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。 |
| $-       | 显示Shell使用的当前选项，与[set命令](https://www.cnblogs.com/linux/linux-comm-set.html)功能相同。 |
| $?       | 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。 |

### sed

匹配给定样式的其中一部分

```
echo this is digit 7 in a num |sed 's/digit \([0-9]\)/\1/'
or
echo this is digit 7 in num|sed  -r 's/digit ([0-7])/\1/'
this is 7 in num
sed -i -r 's/(.*)=PW.+/\1=1234/' test
```

命令中 digit 7，被替换成了 7。样式匹配到的子串是 7，\(..\) 用于匹配子串，对于匹配到的第一个子串就标记为 **\1**，依此类推匹配到的第二个结果就是 **\2**

### sort 

-u 去重

-r  反序排列

-k 通过位置或类型排序

-n 按数值大小排序

-t 指定分隔符

```shell
[root@mail text]# sort -nrk 3 -t: sort.txt
eee:40:5.4
eee:60:5.1
ddd:20:4.2
ccc:50:3.3
bbb:10:2.5
aaa:30:1.6
AAA:BB:CC
```







## ++Problems++

1. 问题: ssh 连接阿里云服务器, 报错`ssh_exchange_identification: read: Connection reset by peer`

   解决历程:

   ```
   1. 首先使用ssh -v 查看连接细节, 未发现有用异常
      ssh docker@47.254.36.21 -v
   OpenSSH_7.6p1 Ubuntu-4, OpenSSL 1.0.2n  7 Dec 2017
   debug1: Reading configuration data /etc/ssh/ssh_config
   debug1: /etc/ssh/ssh_config line 19: Applying options for *
   debug1: Connecting to 47.254.36.21 [47.254.36.21] port 22.
   debug1: Connection established.
   debug1: permanently_set_uid: 0/0
   debug1: identity file /root/.ssh/id_rsa type 0
   debug1: key_load_public: No such file or directory
   debug1: identity file /root/.ssh/id_rsa-cert type -1
   debug1: key_load_public: No such file or directory
   ......
   debug1: Local version string SSH-2.0-OpenSSH_7.6p1 Ubuntu-4
   ssh_exchange_identification: read: Connection reset by peer
   2. 在服务器端通过web端登录, 查看sshd的日志报错,发现并没有报错, 亦没有拦截相关信息,由于之前做了登录安全限制,怀疑是被拦截
   服务器的限制: /etc/pam.d/login 中
   auth required pam_tally2.so deny=3 unlock_time=5 even_deny_root root_unlock_time=10
   将此注释后,重启服务,未解决, /etc/hosts.allow 和/etc/hosts.deny 均未有拦截迹象
   3. 对网络进行抓包查看
   ```

   ![](./wireshark1.png)

   ![](./wireshark2.png)

   发现有重置报文,且和正常的ssh 报文有出入

   ![](./sshcap.png)

   ```
   由此怀疑是网络拦截,联系阿里云客服后发现"看您有reset情况，为排除我方拦截影响，您把本地公网ip云盾加白后测试下。云盾访问白名单地址 https://yundun.console.aliyun.com/?p=sc#/sc/visitWhiteList  "
   将本地公网IP地址加入白名单后,能正常连接
   ```
