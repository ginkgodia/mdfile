**zabbix 深度学习**

**Zabbix主要包括5个程序：**

- zabbix_agentd
  - 客户端守护进程，此进程收集客户端数据，例如CPU负载， 内存等信息
- zabbix_get 
  - zabbix 工具， 单独使用的命令，通常server或者proxy 端执行获取远程客户端信息，通常用于排错。
- zabbix_sender
  - zabbix工具， 用于发送数据给server或者proxy，通常用于耗时较长的检查，很多检查非常耗时间，导致zabbix超时，于是我们在脚本执行完毕后，使用sender主动提交数据
- zabbix_proxy
  - zabbix代理守护进程，功能类似于server， 不同的是， 他只是一个中转站
- zabbix_server
- zabbix_java_gateway

