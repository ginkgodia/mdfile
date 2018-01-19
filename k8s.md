**k8s**

#docker

- 注意事项

在Ubuntu/Debian上有UnionFS可以使用，如aufs或者overlay2，而CentOS和RHEL的内核中没有相关驱动,对于这类系统，一般使用devicemapper驱动利用lvm的一些机制来模拟分层存储，这样来做，性能和稳定性会差一点。

docker 安装在CentOS和RHEL系统上，会默认选择devicemapper，为了简化配置，devicemapper运行在一个稀疏文件模拟的块设备，也被称为loop-lvm。

devicemapper +loop-lvm有一个稳定性，性能更差，而且由于其是稀疏文件系统，所以它会不断增长，即/var/lib/docker/devicemapper/devicemapper/data不断增长，而且无法控制，即使删除容器或镜像，但是无法解决，因为这个空间不会进行回收。

对于CentOS用户，在没有UnionFS的情况下，一定要配置direct-lvm给devicemapper,无论是为了性能，稳定性，还是空间利用率。 

配置direct-lvm

@http://blog.opskumu.com/docker-storage-setup.html

@https://www.centos.bz/2016/12/docker-device-mapper-in-practice/



**本次操作选择ubuntu版本**

- docker 镜像

"""

操作系统分为内核空间和用户空间，对linux 而言，在内核启动后，会挂载root文件系统为其提供用户空间支持，而docker镜像，就类似于一个root文件系统

docker镜像是一个特殊的文件系统，除了提供容器运行时所需的程序，库，资源，配置等文件外，还包括了一些为运行时所准备的配置参数，镜像不包含任何动态数据，其内容在构建后也不会再改变

"""

- docker的分层存储

"""

由于镜像都是包含完整操作系统的root文件系统，其体积是庞大的，因此，在docker设计时，就利用了UnionFS技术，将其设计为分层存储的架构。

"""

- docker 容器

"""

按照docker的最佳实践要求，容器不应该向其存储层写入任何数据，容器存储层要保持无状态化，所有的文件写入操作，都应该用数据卷(Volume)，或者绑定宿主目录，在这些位置的读写会跳过容器存储层，直接对宿主(或者网络存储)发生读写，其性能和稳定性更高

"""

- docker仓库

"""

一个docker registry 中可以包含多个仓库(repository)，每个仓库可以包含多个标签(tag),每个标签对应一个镜像

仓库名一般都是两段式路径的形式出现如： nginx/nginx-proxy,前者意味着docker registry多用户环境下的用户名，后者对应的软件名

docker 仓库的公共库：

https://cr.console.aliyun.com/#/accelerator

https://www.daocloud.io/mirror#accelerator-doc

https://hub.docker.com/

"""

##安装docker

**Ubuntu：** 

-------

支持的操作系统版本：

1.  Artful 17.01
2. Zesty 17.04
3. Xenial 16.04(lts)
4. Trusty 14.04(lts)

查看

操作系统版本：

```shell
# lsb_release  -a
LSB Version:	core-9.20160110ubuntu0.2-amd64:core-9.20160110ubuntu0.2-noarch:security-9.20160110ubuntu0.2-amd64:security-9.20160110ubuntu0.2-noarch
Distributor ID:	Ubuntu
Description:	Ubuntu 16.04.2 LTS
Release:	16.04
Codename:	xenial
$ cat /etc/issue
Ubuntu 16.04.2 LTS \n \l
```

卸载旧版本的docker

```shell
$ sudo apt-get remove docker \
               docker-engine \
               docker.io
```

安装Ubuntu 的可选内核模块

从14.04开始，一部分内核模块移到了可选内核模块(linux-image-extra-*) ,以减少内核软件包的体积，AUFS内核驱动属于可选模块的一部分，作为推荐的docker存储层驱动，一般建议安装可选内核模块以使用AUFS

如果没有安装可选内核模块，使用以下命令安装

```
$ sudo apt-get update

$ sudo apt-get install \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
```

安装docker

@https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-docker-ce

-----------

**Centos**

-------

系统要求： centos 7  ,kernel > 3.1

卸载旧版本：

```shell
$ sudo yum remove docker \
           docker-common \
           docker-selinux \
           docker-engine
```

yum 安装新版本

```shell
$ sudo yum install -y yum-utils \
           device-mapper-persistent-data \
           lvm2
# yum 软件源
$ sudo yum-config-manager \
    --add-repo \
    https://mirrors.ustc.edu.cn/docker-ce/linux/centos/docker-ce.repo
# 下载最新版版
$ sudo yum-config-manager --enable docker-ce-edge
# 测试版
$ sudo yum-config-manager --enable docker-ce-test

# 安装docker-ce
清空缓存
$ sudo yum makecache fast
$ sudo yum install docker-ce
```

###添加内核参数

默认配置下，如果出现下列告警

```shell
WARNING: bridge-nf-call-iptables is disabled
WARNING: bridge-nf-call-ip6tables is disabled
```

添加内核参数启用这些功能

```
$ sudo tee -a /etc/sysctl.conf <<-EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
```

重新执行/etc/sysctl.conf 

```shell
$ sudo sysctl -p
```

______

### 建立docker用户组

默认情况下，docker命令会使用Unix socket 与docker 通信，而只有root 用户和docker 组的用户才可以访问docker 引擎的unix socket .出于安全考虑，llinux 并不直接使用root用户，最好的方法是将docker用户加入docker 用户组

建立docker 用户组

```shell
$ sudo groupadd docker
```

将当前用户加入docker组

```shell
$ sudo usermod -aG docker $USER
```

## 获取镜像

docker pull 

``` shell
docker pull [选项] [Docker Registry 地址[：端口号]/]仓库名[：标签]
使用docker pull --help 获得帮助
```

### 运行docker

```shell
$ docker run -it --rm  \
  ubuntu:16.04 \
  bash
  -it : -i 表示交互式操作 -t表示使用终端
  --rm : 表示这个容器退出后就销毁，默认情况下不会使用
  ubuntu:16.04 表示使用ubuntu:16.04镜像为基础来启动容器
  bash: 放在镜像后的是命令，这里我们希望有个交互的shell，因此使用bash
  
```

###列出镜像

```shell
$ docker image ls
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
redis                latest              5f515359c7f8        5 days ago          183 MB
仓库名				   标签 				 镜像ID				创建时间		所占用空间
```

### 删除镜像

```shell
$ docker image rm ID
```

ID可以使用短ID,即没有重复的前几段字符来代替整个ID.

或者使用景象名即<仓库名>：<标签> 来删除镜像

更精确是的使用镜像摘要来删除

```shell
$ docker image ls --digests
REPOSITORY                  TAG                 DIGEST                                                                    IMAGE ID            CREATED             SIZE
node                        slim                sha256:b4f0e0bdeb578043c1ea6862f0d40cc4afe32a4a582f3be235a3b164422be228   6e0c4c8e3913        3 weeks ago         214 MB

$ docker image rm node@sha256:b4f0e0bdeb578043c1ea6862f0d40cc4afe32a4a582f3be235a3b164422be228
Untagged: node@sha256:b4f0e0bdeb578043c1ea6862f0d40cc4afe32a4a582f3be235a3b164422be228sh
```





###镜像体积

docker 镜像在hub上和在本地的大小不一样，主要是镜像的上传和下载都是再压缩状态下的，因此在本地显示的是解压后的大小。 

查看镜像，容器，数据卷所占空间大小

```shell
$ docker system df 
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              24                  0                   1.992GB             1.992GB (100%)
Containers          1                   0                   62.82MB             62.82MB (100%)
Local Volumes       9                   0                   652.2MB             652.2MB (100%)
Build Cache                                                 0B                  0B
```

### 虚悬镜像

有一类镜像没有仓库名，也没有标签，均为<none>

```
<none>               <none>              00285df0df87        5 days ago          342 MB
```

这种现象出现的原因是由于新旧镜像重名，导致旧镜像没有标签。 这种镜像叫做虚悬镜像(dangling image)

查看虚悬镜像：

```shell
$ docker image ls -f dangling=true
```

一般来说，虚悬镜像一级钢失去了存在的价值，可以随意删除

```shell
$ docker image prune
```



### 利用commit理解镜像构成

docker commit 命令除了用于学习外，还有一些特殊的应用场景，比如被入侵后保存现场，但是，不要使用commit来定制镜像，定制镜像应该使用dockerfile 来完成

创建一个docker 容器

```shell
$ docker run --name webserver -d -p 80:80 nginx
```

修改输出页面

```shell
$ docker exec -it webserver bash
root@3729b97e8226:/# echo '<h1>Hello, Docker!</h1>' > /usr/share/nginx/html/index.html
root@3729b97e8226:/# exit
exit
```

我们改变了容器的文件，也就是改变了容器的存储层，我们可以通过docker diff 来查看具体的改动

```shell
$ docker diff webserver
C /usr
C /usr/share
C /usr/share/nginx
C /usr/share/nginx/html
C /usr/share/nginx/html/index.html
C /root
A /root/.bash_history
C /run
A /run/nginx.pid
C /var
C /var/cache
C /var/cache/nginx
A /var/cache/nginx/client_temp
A /var/cache/nginx/fastcgi_temp
A /var/cache/nginx/proxy_temp
A /var/cache/nginx/scgi_temp
A /var/cache/nginx/uwsgi_temp

```

现在我们町治好了变化，我们希望能将其保存下来形成镜像

当我们使用容器，如果不使用卷的话，任何改变都会记录于容器存储层，docker提供了一个docker commit的命令，可以讲存储层他的信息保存下来成为镜像。

docker commit 的语法格式

```
docker commit [选项] <容器ID或容器名> [<仓库名>[：<标签>]]
```

```
$ docker commit \
    --author "ginkgo <aab@gmail.com>" \
    --message "修改了默认网页" \
    webserver \
    nginx:v2
sha256:07e33465974800ce65751acc279adc6ed2dc5ed4e0838f8b86f0c87aa1795214
```

其中 `--author` 是指定修改的作者，而 `--message` 则是记录本次修改的内容。这点和 `git` 版本控制相似，不过这里这些信息可以省略留空. 可以通过docker image ls  来查看定制的新镜像

通过docker history 查看具体的历史记录

```
docker history nginx:v2
IMAGE               CREATED             CREATED BY                                      SIZE                COMMENT
ceff8cd92f35        16 seconds ago      nginx -g daemon off;                            242B                修改了网页
3f8a4339aadd        2 weeks ago         /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon…   0B                  
.....
```

###慎用docker commit

使用docker commit 可以直观的理解分层存储的概念，但是不建议使用

通过观察diff查看，发现，仅仅修改了一个html文件，就改动了这个容器的许多内容，如果进行了其他操作，会导致这个镜像十分臃肿。 

## 使用Dockerfile定制镜像

Dockerfile是一个文本文件，其中包含了一条条的指令(Instruction)，每一条指令构建一层，因此，每一条指令的内容，就是描述该层如何构建

创建一个nginx镜像

在一个空目录中，建立一个文本文件，并命名为Dockerfile

```shell
$ mkdir myng
$ cd myng
$ touch Dockerfile
```

其内容为：

```
FROM nginx  
RUN echo "<h1> hello, docker </h>" >  /usr/share/nginx/html/index.html
```

- FROM 指定基础镜像

所谓定制镜像，就是以一个镜像为基础，在其上进行定制。 FROM指定基础镜像是必须的，并且是第一条指令

在DOCKER仓库中有很多高质量的镜像，例如：nginx，tomcat...，如果没有，使用基础镜像指定。 

除了现有镜像作为基础镜像外，Docker还提供了一个特殊的镜像，叫scratch，这个镜像是虚拟的，并不存在，表示一个空白镜像。 

适用于不需要操作系统提供运行支持的(例如：swarm,coreos/etcd.

- RUN 执行命令

RUN指令来执行命令行命令的。由于强大的能力，RUN指令在指定镜像时最常用的指令之一，其格式有两种

1. shell格式： RUN <command> ,就像直接在命令行输入命令一个样。

```
RUN echo "<h1> hello, docker </h>" >  /usr/share/nginx/html/index.html
```

2. exec 格式： RUN [ " 可执行文件"， "参数1"， "参数2"]  类似于执行函数。 



dockerfile的层数

```shell
FROM debian:jessie

RUN apt-get update
RUN apt-get install -y gcc libc6-dev make
RUN wget -O redis.tar.gz "http://download.redis.io/releases/redis-3.2.5.tar.gz"
RUN mkdir -p /usr/src/redis
RUN tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1
RUN make -C /usr/src/redis
RUN make -C /usr/src/redis install
```

由于Dockerfile终端每一个指令都会建立一层，每一个run，就会建立一层，新建立一层，在其上执行这些命令，执行结束后，commit这一层的修改，构成新的镜像，像示例的7层镜像是无意义的，而且封装了很多编译环境等。 

Union FS是有最大层数限制的，比如AUFS,不超过127层。 

正确写法：

```shell
FROM debian:jessie

RUN buildDeps='gcc libc6-dev make' \
    && apt-get update \
    && apt-get install -y $buildDeps \
    && wget -O redis.tar.gz "http://download.redis.io/releases/redis-3.2.5.tar.gz" \
    && mkdir -p /usr/src/redis \
    && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
    && make -C /usr/src/redis \
    && make -C /usr/src/redis install \
    && rm -rf /var/lib/apt/lists/* \
    && rm redis.tar.gz \
    && rm -r /usr/src/redis \
    && apt-get purge -y --auto-remove $buildDeps
```



这样的好处是编译，安装redis可执行文件，并在最后一行执行了清理操作             

### 构建镜像

在Dockerfile的目录执行：

```
docker build -t nginx:v1 . 
```

**docker build 格式**

```
docker build [选项] <上下文路径/url/->
```

**镜像构建上下文(context)**

docker build 的工作原理：

dicker 在运行时分为Docker 引擎(也就是服务器端的守护进程)和客户端工具，docker的引擎提供了一组REST API，被称为Docker Remote API.而如docker命令这样的客户端工具，则是通过API与Docker引擎交互，从而完成各种功能，因此，我们表面上看是在本机执行各种docker功能，但实际上，一切都是使用的远程调用形式在服务器端(Docker引擎)完成，正式因为这种C/S架构，让我们操作远程服务器的docker 变的轻而易举

#### 如何获得本地文件

docker build 命令构建镜像，其实并非在本地构建，而是在服务器端，也就是在docker 引擎中构建的。 那么在这种C/S架构中，如何才能让服务器端获得本地文件呢？ 

这就引入了上下文的概念，当构建时，用户会指定构建镜像上下文的路径，docker build 命令得知这个路径后，就会将路径下的所有内容打包，上传到docker 引擎，然后获得文件。 

```
COPY ./package.json  /app/
```

并不是要复制执行docker build命令所在的目录下的package.json，而不是复制dockerfile所在目录下的package.json,而是复制上下文(context)目录下的package.json。

### 其他docker build 方法

直接使用git repo构建

```shell
docker build https://github.com/twang2218/gitlab-ce-zh.git#:8.14
```

用给定的tar包构建

```
$ docker build http://server/context.tar.gz
```

从标准输入中读取Dockerfile进行构建

```
docker build - < Dockerfile
或
cat Dockerfile | docker build -
```

从标准输入中读取上下文压缩包进行构建

```
$ docker build - < context.tar.gz
```

##Dockerfile 指令详解

- ###COPY复制文件

和RUN一样，也有两种格式，一种是类似于命令行，一种基于函数调用

```
shell 格式： COPY <源路径>  ... <目标路径>

exec  格式： COPY [ "<源路径1>"，... "<目标路径>"]
```

COPY指令将从构建上下文目录中<源路径>的文件/目录复制到新的一层镜像内的<目标路径位置>

```
COPY fiule /aab/bba
```

源路径有多个，甚至可以是通配符

```
COPY home* /mydir
COPY ho?.t /mydir
```

<目标路径>是容器的绝对路径，也可以是相对路径，相对于工作目录的路径，通过WORKDIR指定。目标路径不需要事先创建，如果目录不存在，会在复制时自动创建

COPY指令，源文件的内容都会保留，包括权限。

- ###ADD 更高级的复制文件

ADD 指令和COPY 的格式和性质基本一致，但是在COPY基础上加了一些功能

1. 源路径可以是一个URL，在这种情况下，docker引擎会试图下载这个链接的文件，放到目标路径下，下载后的文件权限为600 ，如果这个不是想要的权限，还需要在

2. 如果是下载压缩包，需要解压，也需要额外一层的RUN指令进行解压，所以不如直接使用RUN指令，然后再使用wget，curl 工具下载，然后权限处理，解压缩，清理无用文件合适。 该功能不推荐使用。 

3. 如果源路径为一个压缩文件，他会自动解压这个压缩文件到目标路径去。 

   **ADD指令会使镜像构建缓存失效，从而令镜像构建变得比较缓慢**

   **在COPY和ADD中选择时，可以遵循所有的文件复制均用COPY指令，仅仅在需要自动解压缩的场合使用ADD**

- ### CMD容器启动命令

CMD指令的格式和RUN相似，也是两种格式

```
shell 格式： CMD [命令]
exec 格式：  CMD ["可执行文件" ，"参数1"， "参数2"...]
```

Docker 不是虚拟机，而是进程，既然是进程，那么启动容器的时候，需要指定所运行的程序和参数，CMD指令就是用于指定默认的容器主进程的启动命令的。 





