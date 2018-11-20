#!/bin/bash
# 参数为rpm压缩包解压后的路径
workdir=$(cd $(dirname $0);pwd)
path=$1
shell_usage(){
   echo -e "\033[31m Usage sh $0 path/to/unzip \033[0m"
}
if [ $# != 1 ];then
   shell_usage
exit
fi
cd $path
#获取所有已经安装的rpm包的changelog 
echo "#######"
echo -e "\033[1m 目前系统上安装的软件changelog \033[0m"
echo "#######"
for i in $(ls *.rpm);do echo $i; echo ${i%.*}|xargs rpm -q --changelog |head -n 1;done |tee  $workdir/install
#获取解压的rpm包的changelog
echo "#######"
echo -e  "\033[1m 解压包里的软件changelog \033[0m"
echo "#######"
for i in $(ls *.rpm);do echo $i; echo $i|xargs rpm -qp --changelog |head -n 1;done | tee $workdir/unzip
echo -e "\033[1m 打印二者之间的不同 \033[0m"
diff $workdir/install $workdir/unzip