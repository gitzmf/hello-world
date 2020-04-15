# Docker Machine 
## 简介：  
   docker-machine是解决docker运行环境问题。Docker Machine是一种可以让您在虚拟
主机上安装 Docker 的工具，并可以使用 docker-machine 命令来管理主机。
Docker Machine 也可以集中管理所有的docker主机。  
补充：  
    Docker Compose主要解决容器编排问题，当涉及到多容器应用时，使用docker自身的命令部署繁琐
    这个时候可以通过编写docker-compose-*.yml 配置文件实现多容器的创建以及容器间的通信问题。
    Docker Swarm是解决多主机多个容器调度部署得问题，可以用来来管理多主机上的Docker容器的工具，
    可以负责帮你启动容器，监控容器状态。目前基本都使用Kubernets（k8s）进行管理，Docker
    Swarm已经基本败下阵来，但是其思想和设计是非常好的，是整个容器技术的基石。
## Docker Machine环境安装
1. 已安装Docker环境
2. 下载Docker Machine二进制文件并将其解压缩到您的PATH中。
    ```$xlst2
      base=https://github.com/docker/machine/releases/download/v0.16.0 &&
      curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
      sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
      chmod +x /usr/local/bin/docker-machine
    ```
3. 通过显示计算机版本检查安装是否成功
    ```$xslt2
       docker-machine --version
    ```    
4. 安装命令补全脚本
    ```$xslt2
    # 创建补全脚本下载脚本
    nano bash_complate.sh
    # 复制官网中需要添加的脚本内容
    base=https://raw.githubusercontent.com/docker/machine/v0.16.0
    for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
    do
      sudo wget "$base/contrib/completion/bash/${i}" -P /etc/bash_completion.d
    done
    # 执行脚本
    source bash_complate.sh
    # 提示wget命令不存在，进行安装
    yum install wget
    #  要启用docker-machine外壳程序提示，$(__docker_machine_ps1)请PS1在中添加 设置~/.bashrc。          
    PS1='[\u@\h \W$(__docker_machine_ps1)]\$ ' 
    ```   
    
问题：  
    1. raw.githubusercontent.com连接拒绝
        原因因为github是国外网站原因，还有docker文档也是，被墙了，所以访问失败
## Docker Machine命令简介
1. 列出可用机器
   ```xslt2
   docker-machine ls
   ```
2. 创建机器
   demo: 创建名为test的
   ```$xslt2
   docker-machine create --driver virtualbox test
   docker-machine create --driver generic --generic-ip-address 192.168.199.140 host2
   # 参数说明
   -d/--driver  #指定基于什么虚拟化技术的驱动
   --generic-ip-address  #指定要安装宿主机的IP，这里是本地的IP。也就是说，你也可以给别的主机装Docker，前提是SSH root用户免交互登录或私钥认证。
   ```
补充：
   1. 前提需要进行SSH root用户免交互登录或私钥认证
   ```$xslt2
   ssh-keygen
   ssh-copy-id -i root@192.168.199.134
   ```
   2. 过程中出现以下问题
   “At least 192MB more space needed on the / filesystem.”
   ```$xslt2
   linux 空间不够了，怎么办？
   1> 查看空间多少:df -h
   2> 查看当期内核: uname -r
   3> 查找内核 rpm -qa | grep kernel
   4> 删除多余的内核
   su -c 'yum remove kernel-devel-2.6.32-431.20.3.el6.i686'
   5> 删除系统日志 rm -rf /var/log/*
   6> 删除 rm -rf /usr/local/src 注意这里可能存在你安装的文件
   ```
   查看磁盘扩展情况
   ```xslt2
   fdisl -l
   # fdisk -l命令不存在，原因命令fdisk不在你的命令搜索路径中
   whereis fdisk 查看fidsk命令路径
   # 查看命令搜索路径
   echo $PATH
   # 将fdisk添加到当前命令搜索路径中即可
   ln -s /usr/sbin/fdisk /usr/local/bin/
   ```
3. 启动机器
   ```$xslt2
   docker-machine start test 
   ```   
4. 进入机器
   ```$xslt2
   docker-machine ssh test
   ```
5. 查看当前状态激活的机器
   ```$xslt2
   docker-machine active
   ```   
6. 控制远程docker主机
   ```$xsl2
   docker-machine env test
   # 提前执行bash是因为如果从host1环境exit之后会直接断开xshell的连接
   bash
   # 进入test环境中
   eval $(docker-machine env test)
   ```  
7. 其他命令
   ```$xslt2
    staging
    config：查看当前激活状态 Docker 主机的连接信息。
    creat：创建 Docker 主机
    env：显示连接到某个主机需要的环境变量
    inspect：	以 json 格式输出指定Docker的详细信息
    ip：	获取指定 Docker 主机的地址
    kill：	直接杀死指定的 Docker 主机
    ls：	列出所有的管理主机
    provision：	重新配置指定主机
    regenerate-certs：	为某个主机重新生成 TLS 信息
    restart：	重启指定的主机
    rm：	删除某台 Docker 主机，对应的虚拟机也会被删除
    ssh：	通过 SSH 连接到主机上，执行命令
    scp：	在 Docker 主机之间以及 Docker 主机和本地主机之间通过 scp 远程复制数据
    mount：	使用 SSHFS 从计算机装载或卸载目录
    start：	启动一个指定的 Docker 主机，如果对象是个虚拟机，该虚拟机将被启动
    status：	获取指定 Docker 主机的状态(包括：Running、Paused、Saved、Stopped、Stopping、Starting、Error)等
    stop：	停止一个指定的 Docker 主机
    upgrade：	将一个指定主机的 Docker 版本更新为最新
    url：	获取指定 Docker 主机的监听 URL
    version：	显示 Docker Machine 的版本或者主机 Docker 版本
    help：	显示帮助信息
   ```   
## Docker machine卸载
1. 删除所有的计算机
   ```$xslt2
   docker-machine rm -f $(docker-machine ls -q)
   ```   
2. 卸载docker machine
   ```$xslt2
   rm $(which docker-machine)
   ```        
        