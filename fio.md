#### FIO

fio job file

cat aio-bench

```
[global]
ioengine=libaio  
bs=512
userspace_reap
rw=randrw
rwminwrite=20
time_based
runtime=180
direct=1
group_reporting
randrepeat=0
norandommap
ramp_time=6
iodepth=16
iodepth_batch=8
iodepth_low=8
iodepth_batch_complete=8
exitall
[test]
filename=/dev/nvdisk0
numjobs=1
```

- ioengine=libaio libaio 工作的时候需要文件direct方式打开

  libaio 引擎会用这个iodepth值来调用io_setup 准备个可以一次提交iodepth个io的上下文，同时申请一个io请求队列用于保持IO，在压测时， 系统会生成 特定的io请求，往请求队列里扔， 当队列里边的IO个数达到iodepth_batch值的时候，就会调用io_submit 批次提交请求，然后开始调用io_getevents来收割已经完成的IO。 每次收割多少呢？由于收割时， 超时时间设置为0， 所以有多少已经完成就算多少，最多可以收割iodepth_batch_complete值个，随着收割，IO队列里边的iO数就少了，需要重新补充新的IO，什么时候补充呢？ 当IO数目降低到iodepth_low值的时候就可以重新填充，可以保证OS可以看到至少iodepth_low数目的IO在等待。

- bs块大小必须是扇区(512k)的倍数

- userspace_reap 提高异步IO收割的速度

   `With this  flag turned on, the AIO ring will be read directly from user-space to reap events`

- rw=randrw  Random mixed reads and writes

- rwmixwrite=int `Percentage of a mixed workload that should be writes`

- time_based  `If  set,  fio  will  run for the duration of the runtime specified even if the file(s) are completely read or written. It will simply loop over the same workload as many times as the runtime allows`
- direct=1   跳过系统的buffer IO  `If value is true, use non-buffered I/O`

- group_reporting  