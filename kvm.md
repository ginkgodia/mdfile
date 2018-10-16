ESCloud 安装总结：

###  1. 创建KVM虚拟机磁盘空间不足

在磁盘空间充足的目录创建kvm存储池

查看存储池

显示所有的存储池   `virsh pool-list --all`

存储池路径    `/etc/libvirt/storage`

查看默认存储池信息  `virsh poll-info default`

- 通过virt-manager 步骤为：

  `virt-manager `--> <u>Virtual Machine Manager</u> -->Edit -->Connection Details (选择要创建的目录) --> + Add a Storage Volume --> 选择大小，格式

  ![1539601496527](C:\Users\qc.wu\AppData\Roaming\Typora\typora-user-images\1539601496527.png)

- 通过命令行创建

  ```
  virsh pool-define-as pollA --type dir --target /home/pool 定义存储池，指定类型，创建位置，存储池名称
  
  virsh pool-build pollA 创建存储池
  
  virsh pool-start poolA 激活存储池
  
  virsh pool-autostart poolA 存储池自启动
  ```

- 通过xml 定义

  ```
  仿照default的XML文件，编写新创建的的XML文档
  #default 存储池配置文件：
  [root@node3 ~]# virsh pool-dumpxml default 
  <pool type='dir'>
    <name>default</name>
    <uuid>f94a053e-c6a5-43f5-973d-3825a04b9635</uuid>
    <capacity unit='bytes'>48927821824</capacity>
    <allocation unit='bytes'>4251684864</allocation>
    <available unit='bytes'>44676136960</available>
    <source>
    </source>
    <target>
      <path>/var/lib/libvirt/images</path>
      <permissions>
        <mode>0711</mode>
        <owner>0</owner>
        <group>0</group>
      </permissions>
    </target>
  </pool>
  
  
  [root@node3 ~]# cat /home/my-pools/pool.xml 
  <pool type='dir'>
    <name>pool</name>
    <uuid>6e52c3da-d6ae-4016-a97a-32be87e9f8fc</uuid>
    <capacity unit='bytes'>48927821824</capacity>
    <allocation unit='bytes'>4251623424</allocation>
    <available unit='bytes'>44676198400</available>
    <source>
    </source>
    <target>
      <path>/home/img</path>
      <permissions>
        <mode>0755</mode>
        <owner>0</owner>
        <group>0</group>
      </permissions>
    </target>
  </pool>
  
  #创建存储池
  [root@node3 my-pools]# virsh pool-define pool.xml 
  Pool pool defined from pool.xml
  
  [root@node3 my-pools]# virsh pool-list 
   Name                 State      Autostart 
  -------------------------------------------
   default              active     yes       
   pool                 active     no        
   root                 active     yes       
  #设置或取消存储池开机自动启动：--disable  
  [root@node3 my-pools]# virsh pool-autostart  pool
  Pool pool marked as autostarted
  #启用已经定义的存储池：
  [root@node3 my-pools]# virsh pool-start  pool
  Pool pool marked as autostarted
  
  [root@node3 my-pools]# virsh pool-list 
   Name                 State      Autostart 
  -------------------------------------------
   default              active     yes       
   pool                 active     yes       
   root                 active     yes       
  
  #virsh pool-destroy vmdisk #取消激活存储池，数据不做删除
  #virsh pool-delete  vmdisk  #删除存储池定义的目录和数据
  [root@node3 my-pools]# virsh pool-destroy pool
  Pool pool destroyed
  --------------------- 
  
  ```

- 创建存储卷并安装系统



  ```
   a)创建卷
  [root@nova ~]# virsh vol-create-as poolB linux3.qcow2 20G --format qcow2
   b）创建存储池
  [root@nova ~]#virt-install --name=linux3 --os-variant=RHEL6 --ram 1024 --vcpus=1 --disk path=/home/libvirt/images/linux3.qcow2,format=qcow2,size=20,bus=virtio --accelerate --cdrom /home/iso/EMOS_1.6_x86_64.iso --vnc --vncport=5910 --vnclisten=0.0.0.0 --network bridge=br0,model=virtio -noautoconsol
  ```

- 网络存储池

  [https://blog.csdn.net/genglei1022/article/details/81911143](https://blog.csdn.net/genglei1022/article/details/81911143)

###  重启网络导致网络连接失败

- 原因： 由于在系统上配置了大量的临时ip， 当查看当前network 状态时发现其状态为dead ， 所以想通过`service network start`来将network启用起来， 却导致瞬间没网 ^--^

- 一般情况下对一个网络的修改通过下列命令

  ```
  ifup eth0  # 启用网卡
  ifdown eth0 # 停用网卡
  ifconfig eth0 192.168.1.2 netmask 255.255.255.0 up 为网卡配置地址和掩码，并启用
  ifconfig eth0:0 192.168.0.1 netmask 255.255.255.0 up 
  ifconfig eth0:1 192.168.0.2 netmask 255.255.255.0 up  为一块网卡配置多个ip,并启用
  或
  ip addr add 192.168.1.1/24 dev eth0
  ip addr del 192.168.1.1/24 dev eth0
  使用配置文件配置一块网卡配置多个ip
  cp ifcfg-eth0 ifcfg-eth0:1      #复制原来网卡配置
  cp ifcfg-eth0 ifcfg-eth0:2     #复制原来网卡配置
  
  cat ifcfg-eth0:2
  # Advanced Micro Devices [AMD] 79c970 [PCnet32 LANCE]
  DEVICE=eth0:2                                                #此处修改
  BOOTPROTO=static
  BROADCAST=172.28.255.255                    #IP地址的广播地址
  HWADDR=00:0C:29:D5:39:A0                    #MAC地址，不用修改
  IPADDR=172.28.90.202                        #设置新的IP
  NETMASK=255.255.0.0
  NETWORK=172.28.0.0
  ONBOOT=yes
  ```

- 在解决问题中发现的解决方案

  一般情况下网卡启动失败有以下原因：

  1. 和NetworkManager 冲突   --- 这是个坏家伙， 一般直接禁用，禁止开机启动，他会产生各种莫名其妙的缓存， 使你的配置不生效

  2. MAC地址和配置文件中的冲突

     比如在ifcfg-eth0中配置的是一个MAC地址，在/etc/udev/rules.d/70-persistent-net.rules 中的MAC地址冲突

  3. 网卡copy过程中忘记修改对应的网卡名称，mac地址

  查阅了很多资料，但是还是没有解决问题，最后放大招   重启服务器 ^---^







