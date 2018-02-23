
#!/bin/bash，声明脚本采用bash作为shell。#chkconfig后面三个参数分别表示服务在哪几个运行级别启动（本例是在2,3,4,5），在启动和关闭时服务脚本执行的优先级。#description是对该服务的描述。加上这两行之后才能用chkconfig命令添加服务。另外，服务脚本最好放在/etc/init.d/目录下

#一个linux服务脚本必须包含start,stop和restart，而status不是必须的。关于status有两种方式实现以查看程序的运行状态，一种为上文提到的根据程序的特点自行编写判断脚本，另一种则是利用linux自带的/etc/init.d/functions这个脚本中包含了下面包含的status函数，来打印当前服务进程的状态，当然前提是运行的程序能够产生pid文件
# 1、/var/run

# 根据linux的文件系统分层结构标准（FHS）中的定义：

# /var/run目录中存放的是自系统启动以来描述系统信息的文件。比较常见的用途是daemon进程将自己的pid保存到这个目录。FHS标准要求这个文件夹中的文件必须是在系统启动的时候清空，以便建立新的文件。
# 为了达到这个要求，某些linux中/var/run使用的是tmpfs文件系统，这是一种存储在内存中的临时文件系统，当机器关闭的时候，文件系统自然就被清空了。使用df -Th命令能看到类似的输出结果:
# 文件系统    类型    容量  已用  可用 已用%% 挂载点
# none         tmpfs    990M  384K  989M   1% /var/run
# none         tmpfs    990M     0  990M   0% /var/lock
# 当然/var/run除了保存进程的pid之外也有其他的作用，比如utmp文件，就是用来记录机器的启动时间以及当前登陆用户的。

# 2、/var/lock/subsys
# /var/lock/subsys/目录表示文件是否上锁,通常与/var/run目录结合使用以判断程序是否进行
# create by Ginkgo
# create time 02-09
# chkconfig:2345 31 61
# description: This is a bash to operation tomcat
prog="tomcat"
BASE_DIR="/usr/local/$prog"
START="$BASE_DIR/bin/catalina.sh start"
SHUTDOWN="$BASE_DIR/bin/catalina.sh stop "
. /etc/init.d/functions
. /etc/profile
RETVAL=0
uid=`id |cut -d " " -f 1 |cut -d "=" -f 2|cut -d "(" -f 1`
# id |awk '{print $1}'|awk -F "=" '{print $2}'|awk -F "(" '{print$1}'
# id |cut -d "=" -f2|cut -d"(" -f1
start() {
    [ $uid -ne 0 ] && exit 4
    if status $prog > /dev/null ; then
    exit 0
    fi 

daemon --user=root  "$START >/dev/null" 
# 使用daemon 以tomcat 用户启动
echo  $"Starting $prog: "
        RETVAL=$?
        if [ $RETVAL -eq 0 ] ; then
                touch /var/lock/subsys/$prog
                [ ! -f /var/run/${prog}.pid ] &&
                    /usr/bin/pgrep -f "$prog/conf" > /var/run/${prog}.pid
        fi
        return $RETVAL
}


stop() {
        echo -n $"Stopping $prog: "
        #kill -9 `cat /var/run/${prog}.pid`
killproc $prog
        RETVAL=$?
        echo
        [ $RETVAL -eq 0 ] && {
                rm -f /var/lock/subsys/$prog
                rm -f /var/run/${prog}.pid
        }
        return $RETVAL
}


case $1 in
  start)
start
RETVAL=$?
;;
  stop)
stop
RETVAL=$?
;;
  restart|reload)
stop
start
RETVAL=$?
;;
  status)
        status $prog
        RETVAL=$?
        ;;
  *)
        echo $"Usage: $0 {start|stop|status|restart|reload}"
        RETVAL=2
        ;;
esac


