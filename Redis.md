**Redis**

# 基础设置

##1.修改配置文件和密码

centos 可以通过yum 安装redis

安装后，设置redis密码，登陆认证

```
将requirepass foobared修改为自己想要的密码

requirepass ginkgo

连接redis 验证：
redis-cli -h hostip -p listen port -a password
```

```
redis.conf文件默认在/etc目录下，你可以更改它的位置和名字，更改后，注意在文件/usr/lib/systemd/system/redis.service中，把ExecStart=/usr/bin/redis-server /etc/redis/6379.conf --daemonize no中的redis.conf的路径改成的新的路径
```

