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
2.  Zesty 17.04
3.  Xenial 16.04(lts)
4.  Trusty 14.04(lts)

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

- ###ENTRYPOINT入口点

ENTRYPOINT的目的和CMD一样，都是在指定容器启动程序及参数，当指定了entrypoint后，cmd的含义就发生了变化，不再是直接的运行其命令，而是将cmd的内容作为参数传递给entrypoint指令。

作用：

1. 让镜像变成命令一样使用

假设我们需要一个得知当前公网ip的镜像，如果使用CMD来实现：

```shell
FROM ubuntu:16.04
RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
CMD [ "curl", "-s", "http://ip.cn" ]
```

我们使用docker build -t myip . 来创建镜像，可以通过执行该镜像，获得ip 。 docker run myip 会获得当前的公网ip信息，但是如果我们项获得http头信息，就需要加上-i 参数，那么我们是没有办法直接加-i 参数的，因为，对于CMD来说，如果在docker run 后边加上参数，那么cmd的命令就会被替代。 -i 是无法单独执行的。 需要使用curl -s http://ip.cn -i

但是，如果我们使用ENTRYPOINT的话，因为他是将docker run 后边的命令作为参数传递给ENTRYPOINT的，所以，他将-i 作为参数传递给curl -s http://ip.cn 就完成了任务。

2.应用运行前的准备工作

启动容器就是驱动进程，但有些时候，启动主进程之前，需要一些准备操作。

比如： mysql类的数据库，有可能需要一些配置，初始化操作，这些工作要在最终的mysql服务器运行之前解决。

这些操作是和容器CMD无关的，因为无论CMD执行什么，都需要事先进行一个预处理，这种情况下，可以写一个脚本，然后放入ENTRYPOINT中执行，而这个脚本会接收到参数作为命令，最后在脚本执行。

# RUN & CMD & ENTRYPOINT详解

- RUN执行命令并创建新的镜像层，RUN经常用于创建安装软件包
- CMD设置容器启动后默认执行的命令及参数，但CMD能被docker run后面跟的命令行参数替换掉
- ENTRYPOINT配置容器启动时运行的命令。

**RUN**

RUN在当前镜像的顶部执行命令，并创建新的镜像层

通常： apt-get update 和apt-get install 被放在一个RUN指令中执行，这样能保证每次安装的是最新的包，如果apt-get install 在单独的RUN中执行，则会使用apt-get update 创建的镜像层，而这一层可能是很久以前缓存的。

**CMD**

CMD指令允许用户指定容器的默认执行命令。

此命令会在容器启动，且docker run 没有其他命令时运行。

如果docker run指定了其他命令，CMD指定的默认命令将被忽略

如果Dockerfile中有多个CMD指令，则仅有最后一个生效 。

**ENTRYPOINT**

ENTRYPOINT指令可让容器以应用程序或者服务的形式运行

ENTRYPOINT看上去和CMD指令很像，他们都要指定要执行的命令及其参数，不同之处在于ENTRYPOINT不会被忽略，除非指定 --entrypoint参数，即使docker run指定了其他命令

## ENV设置环境变量

格式：

```shell
ENV <key> <value>
ENV <key1>=<value1> <key2>=<value2>....
```

在定义环境变量之后，后边的指令都可以使用。

```
ENV VERSION=1.0 DEBUG=on
RUN	curl -i "http://aabb/$VERSION
```

```
ADD、COPY、ENV、EXPOSE、LABEL、USER、WORKDIR、VOLUME、STOPSIGNAL、ONBUILD 支持环境变量展开
```

## ARG构建函数

格式： ARG <参数名>[=<默认值>]

构建函数和ENV效果一样，都是设置环境变量，所不同的是，ARG所设置的环境变量在将来容器运行时的环境变量是不存在的，docker history  可以看到其值，所以不要使用他来保存密码。 

## VOLUME定义匿名卷

格式：

VOLUME ["<路径1>"，"<路径2>" ..]

VOLUME <路径>

容器运行时，应该尽量保持容器存储层不发生写操作，对于数据库类需要保存的动态数据的应用，其数据库文件应该保存于卷中(volume)

```
VOLUME /data
```

这里的/data目录就会在运行时自动挂载为匿名卷，任何向/data中写入的信息都不会记录进容器的存储层，从而保证了容器存储层无状态变化，当然可以覆盖这个挂载设置：

```
docker run -d -v mydata:/data  xxx  
```

使用mydata这个命名卷挂载到了/data位置，替代了Dockerfile中的匿名卷。

## EXPOSE声明端口

格式为：

EXPOSE <端口1> [<端口2> ....]

EXPOSE指令是声明运行时容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就开启这个端口，在dockerfile中写这样的声明有两个好处，一个是帮助镜像使用者理解这个镜像服务的守护端口，一般方便配置映射，另一个用处是在运行时使用随机端口映射时(docker run -P)会自动随机映射EXPOSE端口。

要将 `EXPOSE` 和在运行时使用 `-p <宿主端口>:<容器端口>` 区分开来。`-p`，是映射宿主端口和容器端口，换句话说，就是将容器的对应端口服务公开给外界访问，而 `EXPOSE` 仅仅是声明容器打算使用什么端口而已，并不会自动在宿主进行端口映射。

## WORKDIR指定工作目录

格式:

WORKDIR <工作目录路径>

使用WORKDIR指令可以用来指定工作目录，以后各层的当前目录就会被更改为指定目录，如果不存在，会自动创建。

之前提到一些初学者常犯的错误是把 `Dockerfile` 等同于 Shell 脚本来书写，这种错误的理解还可能会导致出现下面这样的错误：

```
RUN cd /app
RUN echo "hello" > world.txt

```

如果将这个 `Dockerfile` 进行构建镜像运行后，会发现找不到 `/app/world.txt` 文件，或者其内容不是 `hello`。原因其实很简单，在 Shell 中，连续两行是同一个进程执行环境，因此前一个命令修改的内存状态，会直接影响后一个命令；而在 `Dockerfile` 中，这两行 `RUN` 命令的执行环境根本不同，是两个完全不同的容器。这就是对 `Dockerfile` 构建分层存储的概念不了解所导致的错误。

之前说过每一个 `RUN` 都是启动一个容器、执行命令、然后提交存储层文件变更。第一层 `RUN cd /app` 的执行仅仅是当前进程的工作目录变更，一个内存上的变化而已，其结果不会造成任何文件变更。而到第二层的时候，启动的是一个全新的容器，跟第一层的容器更完全没关系，自然不可能继承前一层构建过程中的内存变化。

## USER指定当前用户

格式：

USER <用户名>

USER和WORKDIR相似，都是改变环境状态并影响以后的层。WORKDIR是改变工作目录，USER是改变以后各层的执行指令的身份。这个用户必须存在。

## HEALTHCHECK健康检查

格式：

HEALTHCHECK [选项] CMD<命令> ：设置检查容器健康状况的命令

HEALTHCHEKC NONE 如果基础镜像有健康检查指令，使用这条可以屏蔽。

该功能是1.12引入的指令。在没有健康检查之前，docker引擎只会通过判断容器内主进程是否退出来判断是否异常，当程序进入死锁，死循环时，程序并不会退出，健康检查指令可以指定一行命令，用这行命令来判断主机称是否正常。

当在一个镜像指定了 `HEALTHCHECK` 指令后，用其启动容器，初始状态会为 `starting`，在 `HEALTHCHECK` 指令检查成功后变为 `healthy`，如果连续一定次数失败，则会变为 `unhealthy`。

`HEALTHCHECK` 支持下列选项：

- `--interval=<间隔>`：两次健康检查的间隔，默认为 30 秒；
- `--timeout=<时长>`：健康检查命令运行超时时间，如果超过这个时间，本次健康检查就被视为失败，默认 30 秒；
- `--retries=<次数>`：当连续失败指定次数后，则将容器状态视为 `unhealthy`，默认 3 次。

和 `CMD`, `ENTRYPOINT` 一样，`HEALTHCHECK` 只可以出现一次，如果写了多个，只有最后一个生效

```
FROM nginx
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -fs http://localhost/ || exit 1
```

当运行该镜像后，可以通过 `docker container ls` 看到最初的状态为 `(health: starting)`

在等待几秒钟后，再次 `docker container ls`，就会看到健康状态变化为了 `(healthy)`：

如果健康检查连续失败超过了重试次数，状态就会变为 `(unhealthy)`。

为了帮助排障，健康检查命令的输出（包括 `stdout` 以及 `stderr`）都会被存储于健康状态里，可以用 `docker inspect` 来查看



# 操作容器

## 启动容器

启动方式：

1. 基于镜像新建一个容器并启动
2. 将一个终止状态的容器重新启动。 

docker run 参数：

```
-t 让Docker分配一个伪终端，并绑定都容器的标准输入上
-i 让容器的标注输入保持打开
-d 让容器以守护态运行
```

当利用docker run 来创建容器时，Docker在后台运行的标准操作包括：

```
- 检查本地是否存在指定镜像，不存在从共有仓库下载
- 利用镜像创建并启动一个容器
- 分配一个文件系统，并在只读的镜像层外挂载一层可读写层
- 从宿主主机分配的网桥接口中桥接一个虚拟接口到容器中去
- 从地址池中分配一个ip地址给容器
- 执行用户指定的应用程序
- 执行完毕后容器被终止。 
```

创建一个新的容器：

```
docker run -it ubuntu /bin/bash
```

启动已经终止的容器

```
docker container start CONTAINER ID 
```

获取容器输出信息

```
docker container log [container ID or NAMES]
```

## 终止容器

docker container stop 来终止一个运行终止运行中的容器

docker container ls -a 查看一个终止状态的容器

docker container start启动一个容器

docker container restart 重启一个容器

## 进入容器

使用-d参数后，容器会进入后台，某些时候要进入容器进行操作，包括使用docker  attach 或者docker exec命令。推荐使用exec命令

`attach` 命令

attach 命令是docker 自带命令。

```
docker run -dit ubuntu
docker attach dockerid
```

**如果从这个stdin中exit，会导致容器终止**

`exec`命令

-i -t参数

docker exec后可以跟多个参数

只使用-i 参数，由于没有分配伪终端，没有linux命令提示符，但执行结果仍然可返回。

当-it使用时，会有linux的命令提示符。 

**如果从这个stdin中exit，不会导致容器终止。**

## 导入和导出容器

如果要导出容器： docker export dockerid ,将导出容器快照到本地文件file1

如果要导入容器快照：docker import  file1或者通过url来导入docker import http://aab/image

*注：用户既可以使用 docker load 来导入镜像存储文件到本地镜像库，也可以使用 docker import 来导入一个容器快照到本地镜像库。这两者的区别在于容器快照文件将丢弃所有的历史记录和元数据信息（即仅保存容器当时的快照状态），而镜像存储文件将保存完整记录，体积也要大。此外，从容器快照文件导入时可以重新指定标签等元数据信息。*

## 删除容器

docker container rm 来删除一个处于终止状态的容器

docker container prune 来清理所有终止状态的容器

# 访问仓库

仓库：Repository

注册服务器：Registry

实际上注册服务器是管理仓库的具体服务器，每个服务器上可以有多个仓库，而每个仓库下面有多个镜像。从这方面来说，仓库可以被认为是一个具体的项目或目录。例如对于仓库地址 `dl.dockerpool.com/ubuntu` 来说，`dl.dockerpool.com` 是注册服务器地址，`ubuntu` 是仓库名。

**Docker Hub**

@https://clod.docker.com

登陆： 通过docker login 命令交互输入用户名和密码来登陆

使用docker logout 来退出

###拉取镜像

通过docker search 来查找官方仓库的镜像

通过docker pull 将其下载下来

一般有两种镜像：

1. 类似centos 的镜像，是基础镜像或者根镜像，通常有docker公司创建的
2. xytiao/centos镜像，通常是Docker 用户创建并维护的

通过 --filter=starts=N参数来指定显示收藏量大于N的镜像

###推送镜像

可以登录后通过docker push 命令将自己的镜像推送到docker hub

```
docker tag ubuntu:17.10 xytiao/ubuntu:17.10
docker push xytiao/ubuntu:17.10
```

###自动创建

自动创建（Automated Builds）功能对于需要经常升级镜像内程序来说，十分方便。

有时候，用户创建了镜像，安装了某个软件，如果软件发布新版本则需要手动更新镜像。

而自动创建允许用户通过 Docker Hub 指定跟踪一个目标网站（目前支持 [GitHub](https://github.com/) 或 [BitBucket](https://bitbucket.org/)）上的项目，一旦项目发生新的提交或者创建新的标签（tag），Docker Hub 会自动构建镜像并推送到 Docker Hub 中。

要配置自动创建，包括如下的步骤：

- 创建并登录 Docker Hub，以及目标网站；
- 在目标网站中连接帐户到 Docker Hub；
- 在 Docker Hub 中 [配置一个自动创建](https://registry.hub.docker.com/builds/add/)；
- 选取一个目标网站中的项目（需要含 `Dockerfile`）和分支；
- 指定 `Dockerfile` 的位置，并提交创建。

之后，可以在 Docker Hub 的 [自动创建页面](https://registry.hub.docker.com/builds/) 中跟踪每次创建的状态。

## 私有仓库

docker-registry 是官方提供的工具，可以用于构建私有的镜像仓库。

通过官方的registry镜像来运行。

```
$ docker run -d -p 5000:5000 --restart=always --name registry registry
```

默认情况下，仓库会被创建在容器的/var/lib/registry目录下，可以通过-v参数来指定镜像文件存放在本地的指定路径。

```
$ docker run -d \
  -p 5000:5000 \ 
  -v /opt/data/registry:/var/lib/registry \
  registry
```

### 在私有仓库上传，搜索，下载镜像

建好私有仓库后，就可以使用docker tag 来标记一个镜像，然后将其推送到私有仓库，

```
docker tag IMAGE[:TAG] [REGISTRY_HOST[:REGISTRY_PORT]/]REPOSITORY[:TAG]
docker tag ubuntu:latest 127.0.0.1:5000/ubuntu:lastest
```

使用docker push 上传标记镜像

```
docker push 127.0.0.1:5000/ubuntu:latest
```

使用curl查看仓库中的镜像

```
curl 127.0.0.1:5000/v2/_catalog
```

如果看到{"repositories":["ubuntu"]} 表示成功

**Ubuntu14.04,Debian 7 Wheezy**

对于使用upstart的系统而言，编辑/etc/default/docker文件，在其中的DOCKER_OPTS中增加以下内容：

```
DOCKER_OPTS="--registry-mirror=https://registry.docker-cn.com --insecure-registries=192.168.199.100:5000"
```

然后重启服务。

**Ubuntu 16.04+,Debian 8+,Centos7**

对于使用systemd的系统，请在/etc/docker/daemon.json中写下如下内容，如果不存在，创建

```
{
  "registry-mirror": [
    "https://registry.docker-cn.com"
  ],
  "insecure-registries": [
    "192.168.199.100:5000"
  ]
}
```

对于Docker for Windows ，Docker for mac在设置中添加同样的字符串。

默认的私有仓库不支持https协议，如果要使用https,请参考@https://yeasy.gitbooks.io/docker_practice/content/repository/registry_auth.html 

##数据管理

数据卷管理分为

1. 挂载数据卷(Volumes)
2. 挂载主机目录(Bind mounts)

### 数据卷

数据卷是一个可以供一个或多个容器使用的特殊目录，它绕过ufs，可以提供很多有用的特性

- 数据卷： 可以在容器之间共享和重用
- 对数据卷的修改会马上生效
- 对数据卷的更新不会影响镜像
- 数据卷默认会一直存在，即使容器被删除

数据卷类似有挂载，对应目录中的文件会被隐藏

### 选择-v 还是选择--mount参数

推荐使用--mount

### 创建一个数据卷

```
docker volume create my-vol
```

查看所有的数据卷

```
docker volume ls 
```

在主机中使用以下命令可以查看指定数据卷的信息

```
docker volume inspect my-vol
```

### 启用一个挂载数据卷的容器

在使用docker run的时候，使用--mount 标记来将数据卷挂载到容器内部，可以一次挂载多个数据卷

创建一个名为 `web` 的容器，并加载一个 `数据卷` 到容器的 `/webapp` 目录

```
docker run -d -P \
  --name web \
  --mount source=my-vol, target=/webapp \
  training/webapp \
  python app.py
```

### 查看数据卷的具体信息

查看web容器的信息

```
docker inspect web
```

### 删除数据卷

```
docker volume rm my-vol
```

一般情况下，数据卷和容器的生命周期是独立的。如果想在删除容器的同时删除数据卷，使用docker rm -v命令

很多无主的数据卷会占用很多空间，使用以下命令清理：

```
docker volume prune
```

## 监听主机目录

###挂载一个主机目录作为数据卷

挂载主机目录和挂载数据卷一样，都可以通过-v 或--mount 来进行挂载

```shell
$ docker run -d -P \
    --name web \
    # -v /src/webapp:/opt/webapp \
    --mount type=bind,source=/src/webapp,target=/opt/webapp \
    training/webapp \
    python app.py
```

上述命令加载主机的src/webapp目录到容器的/opt/webapp目录，这个功能在测试时十分有效，可以放置一些本地程序到本地目录中，检查容器是否正常工作，本地目录必须是绝对路径，如果使用-v 参数，如果本地目录不存在会创建，如果使用--mount 参数，本地目录不存在，docker 会报错。

docker挂载主机目录的权限默认是读写，用户可以通过readonly指定为只读。

```
$ docker run -d -P \
    --name web \
    # -v /src/webapp:/opt/webapp:ro \
    --mount type=bind,source=/src/webapp,target=/opt/webapp,readonly \
    training/webapp \
    python app.py

```

如果在容器内的/opt/webapp下创建文件，会报错。

### 查看数据卷的具体信息

```
docker inspect web
挂载主机目录的信息在"Mounts" Key 下：
"Mounts": [
    {
        "Type": "bind",
        "Source": "/src/webapp",
        "Destination": "/opt/webapp",
        "Mode": "",
        "RW": true,
        "Propagation": "rprivate"
    }
],
```

### 挂载一个本地主机文件作为数据卷

--mount 标记可以从主机挂载单个文件到容器

```
$ docker run --rm -it \
   # -v $HOME/.bash_history:/root/.bash_history \
   --mount type=bind,source=$HOME/.bash_history,target=/root/.bash_history \
   ubuntu:17.10 \
   bash

root@2affd44b4667:/# history
1  ls
2  diskutil list
```

这样就可以记录容器内输入过的命令了。 

## 使用网络

Docker允许通过外部访问容器或者容器互联的方式来提供网络服务

### 外部访问容器

容器中可以运行一些网路应用，要让外部也可以访问这些数据，可以通过-P或者-p来端口映射

当使用-P标记时，Docker会随机映射一个49000~49900的端口到容器内开放的网络端口

使用docker container ls 可以看到端口信息

此时访问本机的映射端口就可以访问本容器内提供的网络服务。

同样，通过docker logs 查看对应容器内应用的信息

-p 可以指定要映射的端口，并且，在一个端口上只可以绑定一个容器

支持格式：

```
ip:hostPort:containerPort | ip::containerPort | hostPort:containerPort
```

### 映射所有的接口地址

使用hostport:containerport 的格式映射本地5000到容器5000端口，执行

```
docker run -d -p 5000:5000 training/webapp python a.py
```

此时，会默认绑定本地所有接口上的地址。

### 映射到直嘀咕地址的指定端口

使用ip:hostport:ContainerPort格式指定映射使用一个特定地址

```
$ docker run -d -p 127.0.0.1:5000:5000 training/webapp python app.py
```

### 映射到指定地址的任意端口

使用 `ip::containerPort` 绑定 localhost 的任意端口到容器的 5000 端口，本地主机会自动分配一个端口。

```
$ docker run -d -p 127.0.0.1::5000 training/webapp python app.py
```

还可以使用 `udp` 标记来指定 `udp` 端口

```
$ docker run -d -p 127.0.0.1:5000:5000/udp training/webapp python app.py
```

### 查看映射端口配置

使用docker port来查看当前映射的端口配置， 也可以查看到绑定地址

```
$ docker port NAME 5000
```

注意：容器内有自己的内部网络和IP地址

-p 标记可以多次使用来绑定多个端口

```
$ docker run -d \
    -p 5000:5000 \
    -p 3000:80 \
    training/webapp \
    python app.py
```

### 容器互联

容器互联可以使用--link来是容器互联

现在一般使用docker网络来实现

### 新建网络

```
$ docker network create -d bridge my-net
```

-d 参数指定docker网络类型，有bridge overlay，其中。overlay网络类型用于swarm mode

### 连接容器

运行一个容器并连接到新建的my-net 网络

运行一个容器并连接到新建的 `my-net` 网络

```
$ docker run -it --rm --name busybox1 --network my-net busybox sh

```

打开新的终端，再运行一个容器并加入到 `my-net` 网络

```
$ docker run -it --rm --name busybox2 --network my-net busybox sh

```

再打开一个新的终端查看容器信息

```
$ docker container ls

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
b47060aca56b        busybox             "sh"                11 minutes ago      Up 11 minutes                           busybox2
8720575823ec        busybox             "sh"                16 minutes ago      Up 16 minutes                           busybox1

```

下面通过 `ping` 来证明 `busybox1` 容器和 `busybox2` 容器建立了互联关系

用 ping 来测试连接 `busybox2` 容器，它会解析成 `172.19.0.3`。

这样busybox1 和busybox2建立了互联关系

### 配置DNS

利用Docker的虚拟文件来挂载容器的3 个相关配置文件来自定义容器主机名和DNS

在容器中使用mount命令可以看到挂载信息

```
$ mount
/dev/disk/by-uuid/1fec...ebdf on /etc/hostname type ext4 ...
/dev/disk/by-uuid/1fec...ebdf on /etc/hosts type ext4 ...
tmpfs on /etc/resolv.conf type tmpfs ...
```

这种机制可以让宿主机DNS信息发生更新后，所有的Docker容器内的DNS通过/etc/resolv.conf文件立刻更新

配置全部容器的DNS,可以在/etc/docker/daemon.json文件中增加以下内容来设置

```
{
  "dns" : [
    "114.114.114.114",
    "8.8.8.8"
  ]
}
```

这样，每次启动容器，DNS自动配置

如果用户想手动指定容器配置，可以在docker run时加入以下参数

- -h HOSTNAME 或者 --hostname = HOSTNAME 来设定容器主机名，他会写到容器内的/etc/hostname和/etc/hosts,但在容器外看不到。
- -dns = IP_ADDRESS来添加DNS到容器的/etc/resolv.conf中，让容器用这个配置来解析hosts中的主机名
- --dns-search = DOMAIN 设定容器的搜索域，当设定搜索域为.example.com时，在搜索一个名为host的主机时，DNS不仅搜索host，还会搜索host.example.com

如果没有指定，会默认用主机的配置。

## 高级网络配置

当Docker启动时，会自动在主机上创建一个docker0虚拟网桥，实际上是linux 的一个bridge，他会在挂载到他的网口进行网络转发。

同时，Docker 随机分配一个本地为占用的私有网段中的一个地址分配给docker0接口，启动容器的网口也会自动分配一个同一网段的地址。

当创建一个docker 容器时，同时会创建一对veth pair 接口，当数据包发送到一个接口时，另一个接口也会受到相同的数据包，这对借口一端在容器内，即eth0，另一端会挂载到docker0网桥，名称以veth开头，通过这种方式，容器可以根主机通信，容器之间也可以通信，docker就创建了在主机和所有容器之间的一个虚拟共享网络

## 快速配置指南

下面是一个跟 Docker 网络相关的命令列表。

其中有些命令选项只有在 Docker 服务启动的时候才能配置，而且不能马上生效。

- `-b BRIDGE` 或 `--bridge=BRIDGE` 指定容器挂载的网桥
- `--bip=CIDR` 定制 docker0 的掩码
- `-H SOCKET...` 或 `--host=SOCKET...` Docker 服务端接收命令的通道
- `--icc=true|false` 是否支持容器之间进行通信
- `--ip-forward=true|false` 请看下文容器之间的通信
- `--iptables=true|false` 是否允许 Docker 添加 iptables 规则
- `--mtu=BYTES` 容器网络中的 MTU

下面2个命令选项既可以在启动服务时指定，也可以在启动容器时指定。在 Docker 服务启动的时候指定则会成为默认值，后面执行 `docker run` 时可以覆盖设置的默认值。

- `--dns=IP_ADDRESS...` 使用指定的DNS服务器
- `--dns-search=DOMAIN...` 指定DNS搜索域

最后这些选项只有在 `docker run` 执行时使用，因为它是针对容器的特性内容。

- `-h HOSTNAME` 或 `--hostname=HOSTNAME` 配置容器主机名
- `--link=CONTAINER_NAME:ALIAS` 添加到另一个容器的连接
- `--net=bridge|none|container:NAME_or_ID|host` 配置容器的桥接模式
- `-p SPEC` 或 `--publish=SPEC` 映射容器端口到宿主主机
- `-P or --publish-all=true|false` 映射容器所有端口到宿主主机

## 容器访问控制

容器的访问控制，主要通过 Linux 上的 `iptables` 防火墙来进行管理和实现。`iptables` 是 Linux 上默认的防火墙软件，在大部分发行版中都自带。

### 容器访问外部网络

容器要想访问外部网络，需要本地系统的转发支持。在Linux 系统中，检查转发是否打开。

```
$sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1

```

如果为 0，说明没有开启转发，则需要手动打开。

```
$sysctl -w net.ipv4.ip_forward=1

```

如果在启动 Docker 服务的时候设定 `--ip-forward=true`, Docker 就会自动设定系统的 `ip_forward` 参数为 1。

### 容器之间访问

容器之间相互访问，需要两方面的支持。

- 容器的网络拓扑是否已经互联。默认情况下，所有容器都会被连接到 `docker0` 网桥上。
- 本地系统的防火墙软件 -- `iptables` 是否允许通过。

#### 访问所有端口

当启动 Docker 服务时候，默认会添加一条转发策略到 iptables 的 FORWARD 链上。策略为通过（`ACCEPT`）还是禁止（`DROP`）取决于配置`--icc=true`（缺省值）还是 `--icc=false`。当然，如果手动指定 `--iptables=false` 则不会添加 `iptables` 规则。

可见，默认情况下，不同容器之间是允许网络互通的。如果为了安全考虑，可以在 `/etc/default/docker` 文件中配置 `DOCKER_OPTS=--icc=false` 来禁止它。

#### 访问指定端口

在通过 `-icc=false` 关闭网络访问后，还可以通过 `--link=CONTAINER_NAME:ALIAS` 选项来访问容器的开放端口。

例如，在启动 Docker 服务时，可以同时使用 `icc=false --iptables=true` 参数来关闭允许相互的网络访问，并让 Docker 可以修改系统中的 `iptables` 规则。

此时，系统中的 `iptables` 规则可能是类似

```
$ sudo iptables -nL
...
Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
DROP       all  --  0.0.0.0/0            0.0.0.0/0
...

```

之后，启动容器（`docker run`）时使用 `--link=CONTAINER_NAME:ALIAS` 选项。Docker 会在 `iptable` 中为 两个容器分别添加一条 `ACCEPT` 规则，允许相互访问开放的端口（取决于 `Dockerfile` 中的 `EXPOSE` 指令）。

当添加了 `--link=CONTAINER_NAME:ALIAS` 选项后，添加了 `iptables` 规则。

```
$ sudo iptables -nL
...
Chain FORWARD (policy ACCEPT)
target     prot opt source               destination
ACCEPT     tcp  --  172.17.0.2           172.17.0.3           tcp spt:80
ACCEPT     tcp  --  172.17.0.3           172.17.0.2           tcp dpt:80
DROP       all  --  0.0.0.0/0            0.0.0.0/0

```

注意：`--link=CONTAINER_NAME:ALIAS` 中的 `CONTAINER_NAME` 目前必须是 Docker 分配的名字，或使用 `--name` 参数指定的名字。主机名则不会被识别。

## 映射容器端口到宿主主机的实现

默认情况下，容器可以主动访问到外部网络的连接，但是外部网络无法访问到容器。

### 容器访问外部实现

容器所有到外部网络的连接，源地址都会被 NAT 成本地系统的 IP 地址。这是使用 `iptables` 的源地址伪装操作实现的。

查看主机的 NAT 规则。

```
$ sudo iptables -t nat -nL
...
Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination
MASQUERADE  all  --  172.17.0.0/16       !172.17.0.0/16
...

```

其中，上述规则将所有源地址在 `172.17.0.0/16` 网段，目标地址为其他网段（外部网络）的流量动态伪装为从系统网卡发出。MASQUERADE 跟传统 SNAT 的好处是它能动态从网卡获取地址。

### 外部访问容器实现

容器允许外部访问，可以在 `docker run` 时候通过 `-p` 或 `-P` 参数来启用。

不管用那种办法，其实也是在本地的 `iptable` 的 nat 表中添加相应的规则。

使用 `-P` 时：

```
$ iptables -t nat -nL
...
Chain DOCKER (2 references)
target     prot opt source               destination
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:49153 to:172.17.0.2:80

```

使用 `-p 80:80` 时：

```
$ iptables -t nat -nL
Chain DOCKER (2 references)
target     prot opt source               destination
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:80 to:172.17.0.2:80

```

注意：

- 这里的规则映射了 `0.0.0.0`，意味着将接受主机来自所有接口的流量。用户可以通过 `-p IP:host_port:container_port` 或 `-p IP::port` 来指定允许访问容器的主机上的 IP、接口等，以制定更严格的规则。
- 如果希望永久绑定到某个固定的 IP 地址，可以在 Docker 配置文件 `/etc/docker/daemon.json` 中添加如下内容。

```
{
  "ip": "0.0.0.0"
}
```

## 配置 docker0 网桥

Docker 服务默认会创建一个 `docker0` 网桥（其上有一个 `docker0` 内部接口），它在内核层连通了其他的物理或虚拟网卡，这就将所有容器和本地主机都放到同一个物理网络。

Docker 默认指定了 `docker0` 接口 的 IP 地址和子网掩码，让主机和容器之间可以通过网桥相互通信，它还给出了 MTU（接口允许接收的最大传输单元），通常是 1500 Bytes，或宿主主机网络路由上支持的默认值。这些值都可以在服务启动的时候进行配置。

- `--bip=CIDR` IP 地址加掩码格式，例如 192.168.1.5/24
- `--mtu=BYTES` 覆盖默认的 Docker mtu 配置

也可以在配置文件中配置 DOCKER_OPTS，然后重启服务。

由于目前 Docker 网桥是 Linux 网桥，用户可以使用 `brctl show` 来查看网桥和端口连接信息。

```
$ sudo brctl show
bridge name     bridge id               STP enabled     interfaces
docker0         8000.3a1d7362b4ee       no              veth65f9
                                             vethdda6

```

*注：`brctl` 命令在 Debian、Ubuntu 中可以使用 `sudo apt-get install bridge-utils` 来安装。

每次创建一个新容器的时候，Docker 从可用的地址段中选择一个空闲的 IP 地址分配给容器的 eth0 端口。使用本地主机上 `docker0` 接口的 IP 作为所有容器的默认网关。

```
$ sudo docker run -i -t --rm base /bin/bash
$ ip addr show eth0
24: eth0: <BROADCAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 32:6f:e0:35:57:91 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.3/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::306f:e0ff:fe35:5791/64 scope link
       valid_lft forever preferred_lft forever
$ ip route
default via 172.17.42.1 dev eth0
172.17.0.0/16 dev eth0  proto kernel  scope link  src 172.17.0.3
```

## 自定义网桥

除了默认的 `docker0` 网桥，用户也可以指定网桥来连接各个容器。

在启动 Docker 服务的时候，使用 `-b BRIDGE`或`--bridge=BRIDGE` 来指定使用的网桥。

如果服务已经运行，那需要先停止服务，并删除旧的网桥。

```
$ sudo systemctl stop docker
$ sudo ip link set dev docker0 down
$ sudo brctl delbr docker0

```

然后创建一个网桥 `bridge0`。

```
$ sudo brctl addbr bridge0
$ sudo ip addr add 192.168.5.1/24 dev bridge0
$ sudo ip link set dev bridge0 up

```

查看确认网桥创建并启动。

```
$ ip addr show bridge0
4: bridge0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state UP group default
    link/ether 66:38:d0:0d:76:18 brd ff:ff:ff:ff:ff:ff
    inet 192.168.5.1/24 scope global bridge0
       valid_lft forever preferred_lft forever

```

在 Docker 配置文件 `/etc/docker/daemon.json` 中添加如下内容，即可将 Docker 默认桥接到创建的网桥上。

```
{
  "bridge": "bridge0",
}

```

启动 Docker 服务。

新建一个容器，可以看到它已经桥接到了 `bridge0` 上。

可以继续用 `brctl show` 命令查看桥接的信息。另外，在容器中可以使用 `ip addr` 和 `ip route` 命令来查看 IP 地址配置和路由信息。

## 编辑网络配置文件

Docker 1.2.0 开始支持在运行中的容器里编辑 `/etc/hosts`, `/etc/hostname` 和 `/etc/resolve.conf` 文件。

但是这些修改是临时的，只在运行的容器中保留，容器终止或重启后并不会被保存下来。也不会被 `docker commit` 提交。





# docker-compose

```
cat docker-compose.yml 
version: '2'
services: 

  nginx:
    image: nginx:latest
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/logs:/var/log/nginx
    restart: always
    links:
      - tomcat:tomcat
    ports:
      - "80:80"
  mysql:
    image: mysql:latest
    volumes:
      - ./mysql/lib:/var/lib/mysql
      - ./mysql/mysql.conf.d:/etc/mysql/mysql.conf.d
    restart: always
    ports: 
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: Ginkgo+006
  tomcat:
    image: tomcat:latest
    restart: always
    links:
      - mysql:mysql
    ports:
      - "8080:8080"
    volumes: 
      - ./tomcat/webapps:/usr/local/tomcat/webapps
      - ./tomcat/logs:/usr/local/tomcat/logs

```

```
cat nginx.conf 
user  nginx;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    #gzip  on;

    #include /etc/nginx/conf.d/*.conf;

    upstream publicServer {
         server tomcat:8080;
    } 

    server {
        server_name "localhost";
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        location /publicServer {
            proxy_pass http://publicServer;
            proxy_redirect default;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
       }
    }
}

```

```
cat tomcat/webapps/publicServer/WEB-INF/classes/db.properties 
dataSource.driverClass=com.mysql.jdbc.Driver
dataSource.jdbcUrl=jdbc:mysql://mysql:3306/hrqcbase?useUnicode=true&characterEncoding=utf-8
dataSource.user=root
dataSource.password=Ginkgo+006
dataSource.maxPoolSize=20
dataSource.maxIdleTime = 1000
dataSource.minPoolSize=6
```



## docker-compose 详解

通过curl下载docker-compose 的可执行文件，加权限后就可以使用了

使用：

```
docker-compose [选项] [子命令]
```

选项列表：

- -f 指定配置文件，默认为docker-compose.yml
- -p 指定项目名称，默认为配置文件的上级目录名,如果指定，在其他地方也要指定。
- --verbose 输出详细信息
- -H 指定docker服务器，相当于docker -H

自命令列表：

- build  构建或重建服务器依赖的镜像，配置文件指定build而不是image。服务一旦built，就会被标记为"project_service" ,如果你改变了一个services的 dockerfile或者build 目录中的内容，可以执行docker-compose build来重新rebuild服务。
- config 校验文件并显示解析后的配置
- images 列出services正在使用的image， 需要在包含compose-yml的路径中执行
- events 监控服务下容器的事件
- logs 显示容器的输出内容，会自动使用attach连接到所有容器，然后获取容器的输出。
- port 为一个port binding 打印公共端口。 port  SERVICE PRIVATE_PORT 
- ps 显示当前项目下的容器， -p 可以指定项目名
- up 项目下创建服务并启动容器，如果指定了项目名，其他操作也要带上项目名参数容器名格式：[项目名]_[服务名]——[序号]
- down 移除up 命令创建的容器，网络，挂载点，镜像
- pause 暂停服务下的容器
- unpause 恢复暂停的容器
- rm 删除服务下停止的容器
- exec 在服务下启动的容器中运行命令，需要指定服务名和要执行的命令
- run 创建一个新的服务并运行一个一次性命令，会自动启动相关服务，容器名格式：[项目名]\_[服务名]\_run\_[序号]，且不受start/stop/restart/kill等命令影响，使用时可以指定rm参数，运行完成后自动删除，也可以直接使用container rm 删除。
- scale 设置服务容器的数目，多增少删
- start 开启服务，不指定服务，则指所有
- stop 停止服务，不指定服务，则指所有
- restart 重启服务，不指定服务，则指所有
- kill 向服务发送kill 信号。

## docker-compose.yml 详解

```
version:  "2"
service:
  nginx:
    #指定用于构建镜像的dockerfile的路径，值为字符串
    build:  "."
    #设置容器用户名(镜像中已创建)，默认root
    user: user_docker
    #设置容器主机名
    hostname: docekr-ginkgo
    #容器内root账户是否具有宿主机root账户的权限
    privileged: false
    #always(当容器退出时，docker重启它)
    #on-failure: 10 (容器非正常退出，最多重启10次，10次后不再重启)
    restart: always
    #容器的网络连接类型， my_br时自定义的网桥，使用net选项需要事先创建网桥
    net: my_br
    #挂载点，设置与宿主机之间的路径映射
    #:ro表示只读，默认:rw
    volumes:
      - ./tomcat/log: /usr/local/tomcat/logs:ro
    #与宿主机之间的端口映射
    ports:
      - "8080: 80"
    #设置容器dns，如果设置了net，则此项失效，可以使用本地文件映射容器的/etc/resolvf
    dns: 8.8.8.8
    #设置容器环境,容器的环境可以使用系统变量或者使用对应镜像内的环境变量(官方介绍)
    environment:
      JAVA_OPTS: -Djava.security.egd=file:/dev/.urandom
  
  node.js:
    #使用镜像
    image：node:alpine
    privileged: false
    restart: always
    vloumes:
      - ./node: /usr/local/node
    ports:
      - 3000: 8080
      - 3002: 3002
    #覆盖容器启动后默认执行的命令
    command: sh -c "npm instal ws@1.1.0 express -g && node /usr/local/node/server.js"
    environment:
      NODE_PATH: /usr/local/lib/node_modules
      
   
    
    
    
```

####使用net选项需要事先创建网桥

创建一个名为my_br,网段为192.168.32.0的网桥 (docker 的默认网段为172.17.0.0)

```
docker network create --subnet=192.168.32.0/24 my_br
```

创建dockerfile

```
FROM alpine:latest
MAINTAINER anyesu

RUN echo -e "https://mirror.tuna.tsinghua.edu.cn/alpine/v3.4/main\n\
https://mirror.tuna.tsinghua.edu.cn/alpine/v3.4/community" > /etc/apk/repositories && \
    # 设置时区
    apk --update add ca-certificates && \
    apk add tzdata && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
    # 安装jdk
    apk add openjdk7=7.121.2.6.8-r0 && \
    # 安装wget
    apk add wget=1.18-r1 && \
    tmp=/usr/anyesu/tmp && \
    mkdir -p $tmp && \
    cd /usr/anyesu && \
    # 下载tomcat
    wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-7/v7.0.78/bin/apache-tomcat-7.0.78.tar.gz && \
    tar -zxvf apache-tomcat-7.0.78.tar.gz && \
    mv apache-tomcat-7.0.78 tomcat && \
    # 清空webapps下自带项目
    rm -r tomcat/webapps/* && \
    rm apache-tomcat-7.0.78.tar.gz && \
    cd $tmp && \
    # 下载websocket-demo源码
    wget https://github.com/anyesu/websocket/archive/master.zip && \
    unzip master.zip && \
    proj=$tmp/websocket-master/Tomcat-Websocket && \
    src=$proj/src && \
    tomcatBase=/usr/anyesu/tomcat && \
    classpath="$tomcatBase/lib/servlet-api.jar:$tomcatBase/lib/websocket-api.jar:$proj/WebRoot/WEB-INF/lib/fastjson-1.1.41.jar" && \
    output=$proj/WebRoot/WEB-INF/classes && \
    mkdir -p $output && \
    # 编译java代码
    /usr/lib/jvm/java-1.7-openjdk/bin/javac -sourcepath $src -classpath $classpath -d $output `find $src -name "*.java"` && \
    # 拷贝到tomcat
    mv $proj/WebRoot $tomcatBase/webapps/ROOT && \
    rm -rf $tmp && \
    apk del wget && \
    # 清除apk缓存
    rm -rf /var/cache/apk/* && \
    # 添加普通用户
    addgroup -S group_docker && adduser -S -G group_docker user_docker && \
    # 修改目录所有者
    chown user_docker:group_docker -R /usr/anyesu

# 设置环境变量
ENV JAVA_HOME /usr/lib/jvm/java-1.7-openjdk
ENV CATALINA_HOME /usr/anyesu/tomcat
ENV PATH $PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin

# 暴露端口
EXPOSE 8080

# 启动命令（前台程序）
CMD ["catalina.sh", "run"]
```



## Docker Machine

Docker Machine 是Docker官方编排项目之一，负责在多种平台上快速安装Docker环境，Docker Machine项目基于Go项目语言实现。

 



​ 