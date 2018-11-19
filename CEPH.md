## CEPH

### 归置组

存储池内的归置组（ PG ）把对象汇聚在一起，因为跟踪每一个对象的位置及其元数据需要大量计算——即一个拥有数百万对象的系统，不可能在对象这一级追踪位置

![img](http://docs.ceph.org.cn/_images/ditaa-1fde157d24b63e3b465d96eb6afea22078c85a90.png)

态可以是在集群内（ `in` ）或集群外（ `out` ）、也可以是活着且在运行（ `up` ）或挂了且不在运行（ `down` ）。如果一个 OSD 活着，它也可以是 `in` （你可以读写数据）或者 `out` 集群。如果它以前是 `in` 但最近 `out` 了， Ceph 会把其归置组迁移到其他 OSD 。如果一 OSD `out` 了， CRUSH 就不会再分配归置组给它。如果它挂了（ `down` ）其状态也应该是 `out` 

### 停止自动重均衡

你得周期性地维护集群的子系统、或解决某个失败域的问题（如一机架）。如果你不想在停机维护 OSD 时让 CRUSH 自动重均衡，提前设置 `noout`

```
ceph osd set noout
```

在集群上设置 `noout` 后，你就可以停机维护失败域内的 OSD 了。

```
stop ceph-osd id={num}
```

在定位同一故障域内的问题时，停机 OSD 内的归置组状态会变为 `degraded`

维护结束后，重启OSD。

```
start ceph-osd id={num}
```

最后，解除 `noout` 标志。

```
ceph osd unset noout
```

### command

1. 重启ceph-mon

   ```
   systemctl start ceph-mon@node-x
   在对应的x节点执行
   ```

2. ceph osd set noout

   如果你不想在停机维护 OSD 时让 CRUSH 自动重均衡，提前设置 `noout`

3. 查看ceph 的状态信息

   ```
   ceph --admin-daemon /var/run/ceph/ceph-mon.node-1.asok  mon_status
   
   {
       "name": "node-1",
       "rank": 0,
       "state": "leader",
       "election_epoch": 8,
       "quorum": [
           0,
           1
       ],
       "outside_quorum": [],
       "extra_probe_peers": [
           "192.168.15.3:6789\/0"
       ],
       "sync_provider": [],
       "monmap": {
           "epoch": 2,
           "fsid": "5eec9ff7-b925-47d8-97cf-8b35418807ae",
           "modified": "2018-11-13 12:25:18.544256",
           "created": "2018-11-13 11:33:30.630617",
           "mons": [
               {
                   "rank": 0,
                   "name": "node-1",
                   "addr": "192.168.15.2:6789\/0"
               },
               {
                   "rank": 1,
                   "name": "node-2",
                   "addr": "192.168.15.3:6789\/0"
               }
           ]
       }
   }
   ```
