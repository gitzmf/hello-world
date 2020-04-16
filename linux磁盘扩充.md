# Linux磁盘扩充

1. 查看当前文件系统，发现/dev/mapper/cenos-root已不够用，使用率达97%

   ```
   [root@zmf ~]# df -h
   Filesystem               Size  Used Avail Use% Mounted on
   /dev/mapper/centos-root   7.6G  7.6G  200k  97% /
   devtmpfs                 487M     0  487M   0% /dev
   tmpfs                    497M     0  497M   0% /dev/shm
   tmpfs                    497M  6.8M  490M   2% /run
   tmpfs                    497M     0  497M   0% /sys/fs/cgroup
   /dev/sda1                497M  124M  373M  25% /boot
   tmpfs                    100M     0  100M   0% /run/user/0
   ```

2. 查看磁盘空间大小，如果磁盘空间不够，需要进行扩充

   ```
   [root@zmf ~]# fdisk -l
   Disk /dev/sda: 16.1 GB, 16106127360 bytes, 31457280 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: dos
   Disk identifier: 0x00027253
   ```

3. 查看/dev/sda分区，目前有/dev/sda1和/dev/sda2两个分区

   ```
   [root@zmf ~]# fdisk /dev/sda
   Welcome to fdisk (util-linux 2.23.2).
   Changes will remain in memory only, until you decide to write them.
   Be careful before using the write command.
   
   Command (m for help): p
   Disk /dev/sda: 16.1 GB, 16106127360 bytes, 31457280 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: dos
   Disk identifier: 0x00027253
      Device Boot      Start         End      Blocks   Id  System
   /dev/sda1   *        2048     1026047      512000   83  Linux
   /dev/sda2         1026048    16777215     7875584   8e  Linux LVM
   ```

4. 创建分区

   ```
   Command (m for help): n　　　　　　　# 新增加一个分区
   p　　　　　　　# 分区类型我们选择为主分区 
   3　　　　　　  # 分区号输入3（因为1,2已经用过了,sda1是分区1,sda2是分区2,sda3分区3） 
   回车　　　　　 # 默认（起始扇区） 
   回车　　　　　 # 默认（结束扇区） 
   t　　　　　　　# 修改分区类型 
   3　　　　　　  # 选分区3 
   8e　　　　　 　# 修改为LVM（8e就是LVM）
   w　　　　　  　# 写分区表 
   q　　　　　  　# 完成，退出fdisk命令
   ```

5. 重新启动

   ```
   [root@zmf ~]# reboot
   ```

6. 格式化/dev/sda3分区

   ```
   [root@zmf ~]#mkfs.ext3 /dev/sda3
   ```

7. 添加新LVM到已有的LVM组，实现扩容

   ```
   [root@zmf ~]#lvm　　　　　　　　# 进入lvm管理
   lvm>pvcreate /dev/sda3　　     # 这是初始化刚才的分区3
   lvm>vgextend centos /dev/sda3 # 将初始化过的分区加入到虚拟卷组centos (卷和卷组的命令可以通过 vgdisplay )
   lvm>vgdisplay -v  # 查看卷大小
   # 扩展已有卷的容量（6143 是通过vgdisplay查看free PE /Site的大小）
   lvm>lvextend -l+1761 /dev/mapper/centos-root 
   lvm>pvdisplay # 查看卷容量，这时你会看到一个很大的卷了
   lvm>quit 　# 退出
   ```

8. 上面只是卷扩容了，下面是文件系统的真正扩容，输入以下命令：

   ```
   xfs_growfs /dev/mapper/centos-root
   ```

9. 再次查看，已经扩容成功

   ```
   [root@zmf ~]# df -lh
   Filesystem               Size  Used Avail Use% Mounted on
   /dev/mapper/centos-root   14G  6.9G  6.8G  51% /
   devtmpfs                 487M     0  487M   0% /dev
   tmpfs                    497M     0  497M   0% /dev/shm
   tmpfs                    497M  6.9M  490M   2% /run
   tmpfs                    497M     0  497M   0% /sys/fs/cgroup
   /dev/sda1                497M  124M  373M  25% /boot
   tmpfs                    100M     0  100M   0% /run/user/0
   ```

   