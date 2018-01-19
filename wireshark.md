**Wireshark 网络分析器使用介绍：**

 Wireshark 有两种过滤器:

- 捕捉过滤器(CaptureFilters) :用于决定将什么样的信息记录在捕捉结果中。 
- 显示过滤器(DisplayFilters) : 用于在捕捉结果中进行详细查找

二者支持的语法不一样：

捕捉过滤器仅支持协议过滤，显示过滤器既支持协议过滤，又支持内容过滤



**捕捉过滤器-捕捉前依据协议的相关信息进行过滤设置**

语法： Protocol  Direction  Host(s) Value Logical Operations Other expression

例子：tcp 		dst 		 1.1.11     90        and                             tcp dst 1.1.1.1 3128

**protocol(协议)：**

- ether,fddi,ip,arp,rarp,decnet,lat,sca,moprc,mopdl,tcp and udp

如果没有指明协议，那么默认使用所有的协议

**Direction(方向)**

- src, dst, src and dst , src or dst

如果没有特别指定来源或者目标，默认使用src or dst 作为关键字

```
host 10.1.1.1  eq src or dst host 10.1.1.1 
```

**hosts**

-  net , port , host, portrange

如果没有指定，默认使用host关键字

```
src 10.1.1.1 eq src host 10.1.1.1
```

**Logical Operations (逻辑运算)**

- not , and , or 

"not "优先级最高,"or" 和"and" 具有相同的优先级，运算时从左向右进行

**例子：**

```
tcp dst port 80

显示目标的TCP端口为80 的封包

ip src host 10.1.1.1 

显示来源IP地址10.1.1.1 的封包

host 10.1.1.1

显示目标或来源IP地址为10.1.1.1 的封包

src portrange 2000-2999

显示来源为UDP或TCP,并且端口号在2000-2999范围的所有封包

not icmp 

显示不是icmp以外的所有封包

src host 10.1.1.1 and not dst  net 10.1.1.0/24

显示来源IP地址为10.7.2.12 但目的不是10.1.1.0网段的封包

src host 10.4.1.12 or src net 10.6.0.0/16) and tcp dst portrange 200-10000 and dst net 10.0.0.0/8

显示来源IP为10.4.1.12或者来源网络为10.6.0.0/16，目的地TCP端口号在200至10000之间，并且目的位于网络10.0.0.0/8内的所有封包

```





**过滤方式**



- 过滤MAC地址

```
ether host 00:08:ca:86:f8:aa
ether src host 00:08:ca:86:f8:aa
ether dst host 00:08:ca:86:f8:aa
```

- 过滤ip地址

```
host 192.168.1.156
src host 192.168.1.156
```

- 过滤端口

```
port 80
! port 80
src port 80
```

- 过滤协议

```
arp 
icmp
```

- 综合过滤

```
ether host 00:08:ca:86:f8:aa and  ip host 192.11.1.11
```





**显示过滤器**

语法： protocol String1 string2  comparison operator value   logical options other expression

例子： ftp            passive   ip                        ==                 10.1.1.1        xor                  icmp.type

**Protocal**

可以只用OSI模型第2至第七层的协议，可以在Expression(表达式) 查看

**String1 ,String2(可选项)**

协议的子类，点击协议，展开后的项

**Comparison operations(比较运算符)**

英文写法：	C语言写法： 		含义：

eq 			     == 			等于

ne 			     != 			不等于

gt 				> 			大于

lt				< 			小于

ge				>=			大于等于

le				<= 			小于等于

**Logical expressions(逻辑运算符)**

and 			&&			逻辑与

or				||			逻辑或

xor				^^			逻辑异或

not				！			逻辑非

**example:**

```python
tcp.dstport 80 xor tcp.dstport 443 
只有当目的TCP端口为80或者为443(但又不能满足这两点)时，封包被显示

snmp||dns||icmp
显示SNMP或DNS或ICMP封包

ip.src!=10.1.1.1 or ip.dst!= 10.1.1.2
显示来源不为10.1.1.1 或者目的不为10.1.1.2 的封包

tcp.flags.syn == 0x02
显示包含TCP SYN 标志的封包
```





