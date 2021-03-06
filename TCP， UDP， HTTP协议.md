# TCP， UDP， HTTP协议

两个进程在计算机内部通信，可以有管道，内存共享，信号量，消息队列等方法。

在本地通过PID来唯一标识一个进程。

在网络中， IP层的ip地址可以唯一标识一台主机， TCP层的协议和端口号可以唯一标识唯一主机上的一个进程，这种将IP地址+协议+端口号唯一标识网络中的一个进程

在 OSI 的七层协议中，第二层（数据链路层）的数据叫「Frame」，第三层（网络层）上的数据叫「Packet」，第四层（传输层）的数据叫「Segment」

## TCP

TCP 报文分为TCP首部和数据部分两部分组成

![TCP 首部的组成](http://om6ayrafu.bkt.clouddn.com/post/understand-tcp-udp/CFC6314E4B2FD039C450821D946E93E2.png)

### 源端口和目标端口

各占2个字节，共四个字节，每个字节占8位。

### 序号Seq

占4个字节，TCP 是面向字节流的，在一个 TCP 连接中传输的字节流中的每个字节都按照顺序编号。
例如 100 kb 的 HTML 文档数据，一共 102400 (100 * 1024) 个字节，那么每一个字节就都有了编号，整个文档的编号的范围是 0 ~ 102399。

序号字段值指的是'本报文段' 所发送的数据的第一个字节的序号。

TCP协议是面向字节流的，发送是按照字段发送的。将100kb的文档分割成四等分后，第一个TCP字段包含的是25kb数据，即0-25599字节，该报文的序号值就是0.第二个TCP字段包含的是第25600-51199字节，该报文的值就是25600

根据8位一个字节，四个字节可以表示的范围是[0~2^32]，一共4294967296个序号，当序号增大到最大值时，下个序号回到0.

TCP协议可以对4GB的数据进行编号，在一般情况下，可以保证当序号重复使用时， 旧序号早已经到达网络终点或丢失了。 

###确认号ACK

占4个字节，表示期望收到对方下一个报文段的序号值。

TCP 的可靠性，是建立在「每一个数据报文都需要确认收到」的基础之上的。
就是说，通讯的任何一方在收到对方的一个报文之后，都要发送一个相对应的「确认报文」，来表达确认收到。
那么，确认报文，就会包含确认号。
例如，通讯的一方收到了第一个 25kb 的报文，该报文的 序号值=0，那么就需要回复一个**确认报文**，其中的确认号 = 25600.

### 数据偏移Offset

占0.5个字节，4位。

这个字段实际上是指出了 TCP 报文段的首部长度，它指出了 TCP报文段的数据起始处 距离 TCP报文的起始处 有多远。（注意 数据起始处 和 报文起始处 的意思）

一个数据偏移量 = 4 byte，由于 4 位二进制数能表示的最大十进制数字是 15，因此数据偏移的最大值是 60 byte，这也侧面限制了 TCP 首部的最大长度

### 保留Reserved

占0.75个字节6位。

保留为今后使用，目前置为0	

### 标志位TCP Flags

标志位，一共有 6 个，分别占 1 位，共 6 位 。
每一位的值只有 0 和 1，分别表达不同意思

- #### 紧急 URG (Urgent)

  当 URG = 1 的时候，表示紧急指针（Urgent Pointer）有效。
  它告诉系统此报文段中有紧急数据，应尽快传送，而不要按原来的排队顺序来传送。
  URG 要与首部中的 紧急指针 字段配合使用

- #### 确认 ACK (Acknowlegemt)

  当 ACK = 1 的时候，确认号（Acknowledgemt Number）有效。
  一般称携带 ACK 标志的 TCP 报文段为「确认报文段」。
  TCP 规定，在连接建立后所有传送的报文段都必须把 ACK 设置为 1

- #### 推送 PSH (Push)

  当 PSH = 1 的时候，表示该报文段高优先级，接收方 TCP 应该尽快推送给接收应用程序，而不用等到整个 TCP 缓存都填满了后再交付

- #### 复位 RST (Reset)

  当 RST = 1 的时候，表示 TCP 连接中出现严重错误，需要释放并重新建立连接。
  一般称携带 RST 标志的 TCP 报文段为「复位报文段」

- #### 同步 SYN (SYNchronization)

  当 SYN = 1 的时候，表明这是一个请求连接报文段。
  一般称携带 SYN 标志的 TCP 报文段为「同步报文段」。
  在 TCP 三次握手中的第一个报文就是同步报文段，在连接建立时用来同步序号。
  对方若同意建立连接，则应在响应的报文段中使 SYN = 1 和 ACK = 1

- #### 终止 FIN (Finis)

  当 FIN = 1 时，表示此报文段的发送方的数据已经发送完毕，并要求释放 TCP 连接。
  一般称携带 FIN 的报文段为「结束报文段」。
  在 TCP 四次挥手释放连接的时候，就会用到该标志

### 窗口大小WS

占 2 字节。
该字段明确指出了现在允许对方发送的数据量，它告诉对方本端的 TCP 接收缓冲区还能容纳多少字节的数据，这样对方就可以控制发送数据的速度。
窗口大小的值是指，从本报文段首部中的确认号算起，接收方目前允许对方发送的数据量。
例如，假如确认号是 701 ，窗口字段是 1000。这就表明，从 701 号算起，发送此报文段的一方还有接收 1000 （字节序号是 701 ~ 1700） 个字节的数据的接收缓存空间

### 校验和 TCP Checksum

占 2 个字节。
由发送端填充，接收端对 TCP 报文段执行 CRC 算法，以检验 TCP 报文段在传输过程中是否损坏，如果损坏这丢弃。
检验范围包括首部和数据两部分，这也是 TCP 可靠传输的一个重要保障。

### 紧急指针Urgent Pointer

占 2 个字节。
仅在 URG = 1 时才有意义，它指出本报文段中的紧急数据的字节数。
当 URG = 1 时，发送方 TCP 就把紧急数据插入到本报文段数据的**最前面**，而在紧急数据后面的数据仍是普通数据。
因此，紧急指针指出了紧急数据的末尾在报文段中的位置



![TCP 的三次握手和四次挥手](http://om6ayrafu.bkt.clouddn.com/post/understand-tcp-udp/08EAF7F3E7FFCEF3E781385BF62BA2BC.png)



**四次挥手的原因在于在关闭状态中有个半关闭的概念**

这个概念是说，TCP 的连接是全双工（可以同时发送和接收）的连接，因此在关闭连接的时候，必须关闭传送和接收两个方向上的连接。
客户端给服务器发送一个携带 FIN 的 TCP 结束报文段，然后服务器返回给客户端一个 确认报文段，同时发送一个 结束报文段，当客户端回复一个 确认报文段 之后，连接就结束了

### 套接字接口Socket Interfaces

套接字接口是一组函数，由操作系统提供，用以创建网络应用。 大多数现代操作系统都实现了套接字接口

从 Linux 内核的角度来看，一个套接字就是通信的一个端点。 从 Linux 程序的角度来看，套接字是一个有相应描述符的文件。 普通文件的打开操作返回一个文件描述字，而 socket() 用于创建一个 socket 描述符，唯一标识一个 socket。 这个 socket 描述字跟文件描述字一样，后续的操作都有用到它，把它作为参数，通过它来进行一些操作

常用的函数有：

- socket()
- bind()
- listen()
- connect()
- accept()
- write()
- read()
- close()

###Socket 的交互流程

![Socket 的交互流程](http://om6ayrafu.bkt.clouddn.com/post/understand-tcp-udp/46872611EB6C0874FE9E4C290E8F3FE9.png)



图中展示了 TCP 协议的 socket 交互流程，描述如下：

+

1. 服务器根据地址类型、socket 类型、以及协议来创建 socket。
2. 服务器为 socket 绑定 IP 地址和端口号。
3. 服务器 socket 监听端口号请求，随时准备接收客户端发来的连接，这时候服务器的 socket 并没有全部打开。
4. 客户端创建 socket。
5. 客户端打开 socket，根据服务器 IP 地址和端口号试图连接服务器 socket。
6. 服务器 socket 接收到客户端 socket 请求，被动打开，开始接收客户端请求，知道客户端返回连接信息。这时候 socket 进入阻塞状态，阻塞是由于 accept() 方法会一直等到客户端返回连接信息后才返回，然后开始连接下一个客户端的连接请求。
7. 客户端连接成功，向服务器发送连接状态信息。
8. 服务器 accept() 方法返回，连接成功。
9. 服务器和客户端通过网络 I/O 函数进行数据的传输。
10. 客户端关闭 socket。
11. 服务器关闭 socket。

#### Socket接口

socket 函数是系统提供的接口，操作系统大多数都是用 C/C++ 开发的， 自然函数库也是C/C++代码

#### **Socket函数**

该函数会返回一个套接字描述符（socket descriptor），但是该描述符仅是部分打开的，还不能用于读写。 如何完成打开套接字的工作，取决于我们是客户端还是服务器。

**函数原型**

```shell
#include <sys/socket.h>

int socket(int domain, int type, int protocol);
```

#### 参数说明

**domain**: 协议域，决定了 socket 的地址类型，在通信中必须采用对应的地址。 常用的协议族有：`AF_INET`（ipv4地址与端口号的组合）、`AF_INET6`（ipv6地址与端口号的组合）、`AF_LOCAL`（绝对路径名作为地址）。 该值的常量定义在 `sys/socket.h` 文件中。

**type**: 指定 socket 类型。 常用的类型有：`SOCK_STREAM`、`SOCK_DGRAM`、`SOCK_RAW`、`SOCK_PACKET`、`SOCK_SEQPACKET`等。 其中 `SOCK_STREAM`表示提供面向连接的稳定数据传输，即 TCP 协议。 该值的常量定义在 `sys/socket.h` 文件中。

**protocol**: 指定协议。 常用的协议有：`IPPROTO_TCP`（TCP协议）、`IPPTOTO_UDP`（UDP协议）、`IPPROTO_SCTP`（STCP协议）。 当值位 0 时，会自动选择 `type` 类型对应的默认协议。

###bind 函数

由服务端调用，把一个地址族中的特定地址和 socket 联系起来。

### 函数原型

```shell
#include <sys/socket.h>

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

```

### 参数说明

**sockfd**: 即 socket 描述字，由 socket() 函数创建。

***addr**： 一个 `const struct sockaddr` 指针，指向要绑定给 `sockfd` 的协议地址。 这个地址结构根据地址创建 socket 时的地址协议族不同而不同，例如 ipv4 对应 `sockaddr_in`，ipv6 对应 `sockaddr_in6`. 这几个结构体在使用的时候，都可以强制转换成 `sockaddr`。 下面是这几个结构体对应的所在的头文件：

1. `sockaddr`： `sys/socket.h`
2. `sockaddr_in`： `netinet/in.h`
3. `sockaddr_in6`： `netinet6/in.h`

> _in 后缀意义：互联网络(internet)的缩写，而不是输入(input)的缩写。

## listen 函数

服务器调用，将 socket 从一个主动套接字转化为一个监听套接字（listening socket）, 该套接字可以接收来自客户端的连接请求。 在默认情况下，操作系统内核会认为 socket 函数创建的描述符对应于主动套接字（active socket）。

### 函数原型

```
#include <sys/socket.h>
int listen(int sockfd, int backlog);

```

### 参数说明

**sockfd**: 即 socket 描述字，由 socket() 函数创建。

**backlog**: 指定在请求队列中的最大请求数，进入的连接请求将在队列中等待 accept() 它们。



# UDP 和 TCP 的不同

TCP 在传送数据之前必须先建立连接，数据传送结束后要释放连接。
TCP 不提供广播或多播服务，由于 TCP 要提供可靠的、面向连接的运输服务，因此不可避免地增加了许多的开销，如确认、流量控制、计时器以及连接管理等。

而 UDP 在传送数据之前不需要先建立连接。接收方收到 UDP 报文之后，不需要给出任何确认。
虽然 UDP 不提供可靠交付，但在某些情况下 UDP 却是一种最有效的工作方式。

简单来说就是：

**UDP：单个数据报，不用建立连接，简单，不可靠，会丢包，会乱序；**

**TCP：流式，需要建立连接，复杂，可靠 ，有序。**

# UDP 概述

UDP 全称 User Datagram Protocol, 与 TCP 同是在网络模型中的传输层的协议。

**UDP 的主要特点是：**

1. **无连接的**，即发送数据之前不需要建立连接，因此减少了开销和发送数据之前的时延。
2. **不保证可靠交付**，因此主机不需要为此复杂的连接状态表
3. **面向报文的**，意思是 UDP 对应用层交下来的报文，既不合并，也不拆分，而是保留这些报文的边界，在添加首部后向下交给 IP 层。
4. **没有阻塞控制**，因此网络出现的拥塞不会使发送方的发送速率降低。
5. **支持一对一、一对多、多对一和多对多的交互通信**，也即是提供广播和多播的功能。
6. **首部开销小**，首部只有 8 个字节，分为四部分。

**UDP 的常用场景：**

1. 名字转换（DNS）
2. 文件传送（TFTP）
3. 路由选择协议（RIP）
4. IP 地址配置（BOOTP，DHTP）
5. 网络管理（SNMP）
6. 远程文件服务（NFS）
7. IP 电话
8. 流式多媒体通信

# UDP 报文结构

UDP 数据报分为数据字段和首部字段。
首部字段只有 8 个字节，由四个字段组成，每个字段的长度是 2 个字节。

![UDP  数据报结构.png](http://om6ayrafu.bkt.clouddn.com/post/understand-tcp-udp/6FCC9F4EDE80F784BD11ED9FA76FA375.png)

**首部各字段意义**：

1. **源端口**：源端口号，在需要对方回信时选用，不需要时可全 0.
2. **目的端口**：目的端口号，在终点交付报文时必须要使用到。
3. **长度**：UDP 用户数据报的长度，在只有首部的情况，其最小值是 8 。
4. **检验和**：检测 UDP 用户数据报在传输中是否有错，有错就丢弃。

# UDP 如何进行校验和

## 伪首部

UDP 数据报首部中检验和的计算方法比较特殊。
在计算检验和时，要在数据报之前增加 12 个字节的伪首部，用来计算校验和。
伪首部并不是数据报真正的首部，是为了计算校验和而临时添加在数据报前面的，在真正传输的时候并不会把伪首部一并发送。

![UDP 数据报结构-伪首部.png](http://om6ayrafu.bkt.clouddn.com/post/understand-tcp-udp/3D9C291187835C3571A111952201B4FF.png)

**伪首部个字段意义**：

1. 第一字段，源 IP 地址
2. 第二字段，目的 IP 地址
3. 第三字段，字段全 0
4. 第四字段，IP 首部中的协议字段的值，对于 UDP，此字段值为 17
5. 第五字段，UDP 用户数据报的长度

## 校验和计算方法

校验和的计算中，频繁用到了二进制的反码求和运算，运算规则见下：

**二进制反码求和运算**

```
0 + 0 = 0
1 + 0 = 0 + 1 = 1
1 + 1 = 10

```

其中 10 中的 1 加到了下一列去，如果是最高列的 1 + 1 ，那么得到的 10 留下 0 , 1 移到最低列，与最低位再做一次二进制加法即可。

**检验和计算过程**

1. 把首部的检验和字段设置为全 0
2. 把伪首部以及数据段看成是许多 16 位的字串接起来。
3. 若数据段不是偶数个字节，则填充一个全 0 字节，但是这个字节不发送。
4. 通过二进制反码运算，计算出 16 位字的和。
   1. 让第一行和第二行做二进制反码运算。
   2. 将第一行和第二行的结果与第三行做二进制反码计算，以此类推。
5. 最后运算结果取反，得到校验和。
6. 把计算出来的校验和值，填入首部校验和字段。

接收方收到数据报之后，按照同样的方法计算校验和，如果有差错，则丢弃这个数据报。

可以看出校验和，既检查了 UDP 用户数据报的源端口号和目的端口号以及数据报的数据部分，又检查了 IP 数据报的源 IP 地址和目的地址。

**一个校验和例子** 假设一个 UDP 数据报：

![UDP 校验和.png](http://om6ayrafu.bkt.clouddn.com/post/understand-tcp-udp/5DADDF7480F81837145468E2ADA6839F.png)

各字段以二进制表示：

```
1001 1001 0001 0011 //伪首部源IP地址前16位，值：153.19
0000 1000 0110 1000 //伪首部源IP地址后16位，值：8.104
1010 1011 0000 0011 //伪首部目的IP地址前16位，值：171.3
0000 1110 0000 1011 //伪首部目的IP地址后16位，值：14.11
0000 0000 0001 0001 //伪首部UDP协议字段代表号，值：17
0000 0000 0000 1111 //伪首部UDP长度字段，值：15
0000 0100 0011 1111 //UDP头部源IP地址对应的进程端口号，值：1087
0000 0000 0000 1101 //UDP头部目的IP地址对应的进程端口号，值：13
0000 0000 0000 1111 //UDP头部UDP长度字段，值：15
0000 0000 0000 0000 //UDP头部UDP检验和，值：0
0101 0100 0100 0101 //数据字段
0101 0011 0101 0100 //数据字段
0100 1001 0100 1110 //数据字段
0100 0111 0000 0000 //数据字段+填充0字段

```

按照二进制反码运算求和，结果：`10010110 11101101`
结果求反码得出校验和：`01101001 00010010`



