## Ansible

### ++Ansible 的配置文件++

- 默认情况下, ansible 按下列顺序查找配置文件

  > 1. ANSIBLE_CFG	环境变量, 可以定义配置文件的位置
  >
  > 2. ansible.cfg 当前工作目录的配置文件
  >
  > 3. ansible.cfg 存在于当前用户家目录
  >
  > 4. /etc/ansible/ansible.cfg

- ansible.cfg 配置文件详解

  | 配置                                                         | 说明                                                         |
  | ------------------------------------------------------------ | ------------------------------------------------------------ |
  | #inventory      = /etc/ansible/hosts                         | 指定主机清单文件                                             |
  | #library        = /usr/share/my_modules/                     | 指定模块地址                                                 |
  | #remote_tmp     = $HOME/.ansible/tmp                         | 指定远程执行的路径                                           |
  | #local_tmp      = $HOME/.ansible/tmp                         | ansible 管理节点得执行路径                                   |
  | #forks          = 5                                          | 置默认情况下Ansible最多能有多少个进程同时工作，默认设置最多5个进程并行处理 |
  | #poll_interval  = 15                                         | 轮询间隔                                                     |
  | #sudo_user      = root                                       | sudo默认用户                                                 |
  | #ask_sudo_pass = True                                        | 是否需要用户输入sudo密码                                     |
  | #ask_pass      = True                                        | 是否需要用户输入连接密码                                     |
  | #transport      = smart                                      |                                                              |
  | #remote_port    = 22                                         | 远程链接的端口                                               |
  | #module_lang    = C                                          | 这是默认模块和系统之间通信的计算机语言,默认为’C’语言.        |
  | #module_set_locale = True                                    |                                                              |
  | #gathering = implicit                                        |                                                              |
  | #gather_subset = all                                         | 定义获取fact的子集，默认全部                                 |
  | #roles_path    = /etc/ansible/roles                          | 角色存储路径                                                 |
  | #host_key_checking = False                                   | 跳过ssh 首次连接提示验证部分，False表示跳过。                |
  | #stdout_callback = skippy                                    |                                                              |
  | #callback_whitelist = timer, mail                            |                                                              |
  | #task_includes_static = True                                 |                                                              |
  | #handler_includes_static = True                              |                                                              |
  | #sudo_exe = sudo                                             | sudo的执行文件名                                             |
  | #sudo_flags = -H -S -n                                       | sudo的参数                                                   |
  | #timeout = 10                                                | 连接超时时间                                                 |
  | #remote_user = root                                          | 指定默认的远程连接用户                                       |
  | #log_path = /var/log/ansible.log                             | 指定日志文件                                                 |
  | #module_name = command                                       | 指定ansible默认的执行模块                                    |
  | #executable = /bin/sh                                        | 用于执行脚本得解释器                                         |
  | #hash_behaviour = replace                                    | 如果变量重叠，优先级更高的一个是替换优先级低得还是合并在一起，默认为替换 |
  | #private_role_vars = yes                                     | 默认情况下，角色中的变量将在全局变量范围中可见。 为了防止这种情况，可以启用以下选项，只有tasks的任务和handlers得任务可以看到角色变量。 |
  | #jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n           | jinja2的扩展应用                                             |
  | #private_key_file = /path/to/file                            | 指定私钥文件路径                                             |
  | #vault_password_file = /path/to/vault_password_file          | 指定vault密码文件路径                                        |
  | #ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host} | 定义一个Jinja2变量，可以插入到Ansible配置模版系统生成的文件中 |
  | #display_skipped_hosts = True                                | 如果设置为False,ansible 将不会显示任何跳过任务的状态.默认选项是显示跳过任务的状态 |
  | #display_args_to_stdout = False                              |                                                              |
  | #error_on_undefined_vars = False                             | 如果所引用的变量名称错误的话, 是否让ansible在执行步骤上失败  |
  | #system_warnings = True                                      |                                                              |
  | #deprecation_warnings = True                                 |                                                              |
  | #command_warnings = False                                    |                                                              |
  | #action_plugins     = /usr/share/ansible/plugins/action      | action模块的存放路径                                         |
  | #callback_plugins   = /usr/share/ansible/plugins/callback    | callback模块的存放路径                                       |
  | #connection_plugins = /usr/share/ansible/plugins/connection  | connection模块的存放路径                                     |
  | #lookup_plugins     = /usr/share/ansible/plugins/lookup      | lookup模块的存放路径                                         |
  | #vars_plugins       = /usr/share/ansible/plugins/vars        | vars模块的存放路径                                           |
  | #test_plugins       = /usr/share/ansible/plugins/test        | test模块的存放路径                                           |
  | #strategy_plugins   = /usr/share/ansible/plugins/strategy    | strategy模块的存放路径                                       |
  | #bin_ansible_callbacks = False                               |                                                              |
  | #nocows = 1                                                  |                                                              |
  | #cow_selection = default                                     |                                                              |
  | #cow_selection = random                                      |                                                              |
  | #cow_whitelist=bud-frogs,bunny,cheese,daemon,default,dragon,elephant-in-snake,elephant,eyes, |                                                              |
  | #nocolor = 1                                                 | 默认ansible会为输出结果加上颜色,用来更好的区分状态信息和失败信息.如果你想关闭这一功能,可以把’nocolor’设置为‘1’: |
  | #fact_caching = memory                                       | fact值默认存储在内存中，可以设置存储在redis中，用于持久化存储 |
  | #retry_files_enabled = False                                 | 当playbook失败得情况下，一个重试文件将会创建，默认为开启此功能 |
  | #retry_files_save_path = ~/.ansible-retry                    | 重试文件的路径，默认为当前目录下.ansible-retry               |
  | #squash_actions = apk,apt,dnf,package,pacman,pkgng,yum,zypper | Ansible可以优化在循环时使用列表参数调用模块的操作。 而不是每个with_项调用模块一次，该模块会一次调用所有项目一次。该参数记录哪些action是这样操作得。 |
  | #no_log = False                                              | 任务数据的日志记录，默认情况下关闭                           |
  | #no_target_syslog = False                                    | 防止任务的日志记录，但只在目标上，数据仍然记录在主/控制器上  |
  | #allow_world_readable_tmpfiles = False                       |                                                              |
  | #var_compression_level = 9                                   | 控制发送到工作进程的变量的压缩级别。 默认值为0，不使用压缩。 此值必须是从0到9的整数。 |
  | #module_compression = 'ZIP_DEFLATED'                         | 指定压缩方法，默认使用zlib压缩，可以通过ansible_module_compression来为每个主机设置 |
  | #max_diff_size = 1048576                                     | 控制--diff文件上的截止点（以字节为单位），设置0则为无限制（可能对内存有影响） |

- 需要被注意的参数有:

  > vault_password_file = /path/to/vault_password_file  # 指定vault密码文件路径 @http://www.ansible.com.cn/docs/playbooks_vault.html
  >
  > remote_port    = 22  # 远端ssh端口   
  >
  > host_key_checking = False  #跳过ssh 首次连接提示验证部分，False表示跳过, 也可以通过 设置环境变量来实现export ANSIBLE_HOST_KEY_CHECKING=False
  >
  > timeout = 10  #This is the default timeout for connection plugins to use
  >
  > connect_timeout  #This controls how long the persistent connection will remain idle before it is destroyed
  >
  > module_name = command #指定ansible默认的执行模块

- 提权方式 <sudo>

  ```
  [privilege_escalation]
  #become=True
  #become_method=sudo
  #become_user=root
  #become_ask_pass=False
  ```

- 连接方式<paramiko和ssh 切换> -根据系统和ssh 版本,需要用到sshpass 软件,ssh 模式必须要添加主机的fingerprint, 无法跳过

  ```
  [paramiko_connection]
  #record_host_keys=False
  #pty=False
  ```

- 连接方式<ssh>

  ```
  #ssh_args = -o ControlMaster=auto -o ControlPersist=60s
  ssh连接时的参数
  #control_path = %(directory)s/ansible-ssh-%%h-%%p-%%r
  保存ControlPath套接字的位置
  #pipelining = False
  SSH pipelining 是一个加速 Ansible 执行速度的简单方法。ssh pipelining 默认是关闭，之所以默认关闭是为了兼容不同的 sudo 配置，主要是 requiretty 选项。如果不使用 sudo，建议开启。打开此选项可以减少 ansible 执行没有传输时 ssh 在被控机器上执行任务的连接数。不过，如果使用 sudo，必须关闭 requiretty 选项。
  #scp_if_ssh = True
  该项为True时，如果连接类型是ssh，使ansible使用scp，为False是，ansible使用sftp。默认为sftp
  #sftp_batch_mode = False
  该项为False时，sftp不会使用批处理模式传输文件。 这可能导致一些类型的文件传输失败而不可捕获，但应该只有在您的sftp版本在批处理模式上有问题时才应禁用
  ```

### ++Ansible 主机清单++

Ansible Inventory实际上是包含静态Inventory和动态Inventory两部分，静态Inventory指的是在文件/etc/ansible/hosts中指定的主机和组，Dynamic Inventory指通过外部脚本获取主机列表，并按照ansible 所要求的格式返回给ansilbe命令的。这部分一般会结合CMDB资管系统、zabbix 监控系统、crobble安装系统、云计算平台等获取主机信息。由于主机资源一般会动态的进行增减，而这些系统一般会智能更新。我们可以通过这些工具提供的API 或者接入库查询等方式返回主机列表。

默认情况下, j静态清单 ansible 使用/etc/ansible/hosts 文件来作为inventory_files,如果要使用非/etc/ansible/hosts 文件作为inventory_files , 那么需要使用-i 来指定文件位置

示例文件

```
mail.example.com # FQDN 

[webservers] # 方括号[]中是组名
host1
host2:5522  # 指定连接主机得端口号
localhost ansible_connection=local # 定义连接类型
host3 http_port=80 maxRequestsPerChild=808 # 定义主机变量
host4 ansible_ssh_port=5555 ansible_ssh_host=192.168.1.50 # 定义主机ssh连接端口和连接地址
www[1:50].example.com # 定义 1-50范围内的主机
www-[a:f].example.com # 定义a-f范围内内的主机

[dbservers]
three.example.com     ansible_python_interpreter=/usr/local/bin/python #定义python执行文件
192.168.77.123     ruby_module_host  ansible_ruby_interpreter=/usr/bin/ruby.1.9.3 # 定义ruby执行文件
 
[webservers:vars]  # 定义webservers组的变量
ntp_server= ntp.example.com
proxy=proxy.example.com


[server:children] # 定义server组的子成员
webservers
dbservers

[server:vars] # 定义server组的变量
zabbix_server:192.168.77.121
```

- Inventory 参数的说明  <可以写在inventory 的文件中>

> 主机连接：
>
> | 参数               | 说明                                                         |
> | ------------------ | ------------------------------------------------------------ |
> | ansible_connection | 与主机的连接类型.比如:local, ssh 或者 paramiko. Ansible 1.2 以前默认使用 paramiko.1.2 以后默认使用 'smart','smart' 方式会根据是否支持 ControlPersist, 来判断'ssh' 方式是否可行.  local  允许在本地执行 This connection plugin allows ansible to execute tasks on the Ansible ‘controller’ instead of on a remote host |
>
> ssh连接参数：
>
> | 参数                         | 说明                                                         |
> | ---------------------------- | ------------------------------------------------------------ |
> | ansible_ssh_host             | 将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置. |
> | ansible_ssh_port             | ssh端口号.如果不是默认的端口号,通过此变量设置.               |
> | ansible_ssh_user             | 默认的 ssh 用户名                                            |
> | ansible_ssh_pass             | ssh 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥) |
> | ansible_ssh_private_key_file | ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况. |
> | ansible_ssh_common_args      | 此设置附加到sftp，scp和ssh的缺省命令行                       |
> | ansible_sftp_extra_args      | 此设置附加到默认sftp命令行。                                 |
> | ansible_scp_extra_args       | 此设置附加到默认scp命令行。                                  |
> | ansible_ssh_extra_args       | 此设置附加到默认ssh命令行。                                  |
> | ansible_ssh_pipelining       | 确定是否使用SSH管道。 这可以覆盖ansible.cfg中得设置。        |
>
> 远程主机环境参数：
>
> | 参数                       | 说明                                                         |
> | -------------------------- | ------------------------------------------------------------ |
> | ansible_shell_type         | 目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'. |
> | ansible_python_interpreter | 目标主机的 python 路径.适用于的情况: 系统中有多个 Python, 或者命令路径不是"/usr/bin/python",比如  *BSD, 或者 /usr/bin/python |
> | ansible_*_interpreter      | 这里的"*"可以是ruby 或perl 或其他语言的解释器，作用和ansible_python_interpreter 类似 |
> | ansible_shell_executable   | 这将设置ansible控制器将在目标机器上使用的shell，覆盖ansible.cfg中的配置，默认为/bin/sh。 |

- 主机动态清单

@http://www.361way.com/ansible-dynamic-inventory/4403.html

> ```
> inventory.py
> #!/usr/bin/env python
> 
> '''
> Example custom dynamic inventory script for Ansible, in Python.
> '''
> 
> import os
> import sys
> import argparse
> 
> try:
>     import json
> except ImportError:
>     import simplejson as json
> 
> class ExampleInventory(object):
> 
>     def __init__(self):
>         self.inventory = {}
>         self.read_cli_args()
> 
>         # Called with `--list`.
>         if self.args.list:
>             self.inventory = self.example_inventory()
>         # Called with `--host [hostname]`.
>         elif self.args.host:
>             # Not implemented, since we return _meta info `--list`.
>             self.inventory = self.empty_inventory()
>         # If no groups or vars are present, return empty inventory.
>         else:
>             self.inventory = self.empty_inventory()
> 
>         print json.dumps(self.inventory);
> 
>     # Example inventory for testing.
>     def example_inventory(self):
>         return {
>             'group': {
>                 'hosts': ['192.168.28.71', '192.168.28.72'],
>                 'vars': {
>                     'ansible_ssh_user': 'vagrant',
>                     'ansible_ssh_private_key_file':
>                         '~/.vagrant.d/insecure_private_key',
>                     'example_variable': 'value'
>                 }
>             },
>             '_meta': {
>                 'hostvars': {
>                     '192.168.28.71': {
>                         'host_specific_var': 'foo'
>                     },
>                     '192.168.28.72': {
>                         'host_specific_var': 'bar'
>                     }
>                 }
>             }
>         }
> 
>     # Empty inventory for testing.
>     def empty_inventory(self):
>         return {'_meta': {'hostvars': {}}}
> 
>     # Read the command line args passed to the script.
>     def read_cli_args(self):
>         parser = argparse.ArgumentParser()
>         parser.add_argument('--list', action = 'store_true')
>         parser.add_argument('--host', action = 'store')
>         self.args = parser.parse_args()
> 
> # Get the inventory.
> ExampleInventory()
> ```
>
> ```
> $ ./inventory.py --list
> {"group": {"hosts": ["192.168.28.71", "192.168.28.72"], "vars":{"ansible_ssh_user": 
> "vagrant","ansible_ssh_private_key_file":"~/.vagrant.d/insecure_private_key", "example_variable": "value"}}, 
> "_meta": {"hostvars": {"192.168.28.72": {"host_specific_var": "bar"}, "192.168.28.71": {"host_specific_var": "foo"}}}}
> 
> $ ansible all -i inventory.py -m ping
> $ ansible all -i inventory.py -m debug -a "var=host_specific_var"
> ```
>

### ++Ansible 模式匹配++

Patterns 是定义Ansible 要管理的主机, 但是在playbook 中它指的时对应主机应用特定的配置或者时IT流程

- 命令行模式

  `ansible <host-pattern> [options]`

- playbook 中

  `- hosts: <host-pattern>`

示例:

`ansible *  -m service -a 'name=httpd state=restart'`

patterns 的使用

> - 匹配所有主机
>
>   all
>
> - 精确匹配主机
>
>   192.168.1.1,192.168.1.2
>
> - 或匹配
>
>   web:db #匹配web组或者db组
>
> - 非匹配
>
>   "web:\!db" #表示匹配的主机在web组, 不在db组 
>
> - 交集匹配
>
>   "web:&db" # 表示匹配的主机同时在db组和dbservers组中
>
> - 通配符匹配
>
>   web-*.com:dbserver
>
>   webserver[0]
>
>   webserver[0:25]
>
>   ` * 表示所有字符, [0] 表示组内第一个成员, [0:25]表示组内第一个到第24个成员`
>
> - 正则表达式匹配
>
>   `~(web|db).*\.example\.com # 在开头使用~表示这是一个正则表达式`
>
> - 组合匹配
>
>   `"webservers:dbservers:&staging:!phoenix"`
>
>   在webservers或dbservers 组中,还必须在staging组中,但不在phoenix组中
>
> - 使用变量
>
>   `webservers:!{{excluded}}:&{{required}}` 在playbook 中, 可以使用吧变量来组成这样的表达式, 但是必须要使用-e 来指定
>
> - 排除条件
>
>   -l  #只执行-l 后边的主机





















