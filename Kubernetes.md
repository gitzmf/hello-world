# Kubernetes
## Kubernetes是什么
   Kubernetes是全新的基于容器化的分布式架构解决方案。
## Kubernetes基本概念和术语
### Node(节点)
   Node是相对于Master主机而言的，Node上运行用于启动和管理Pod的服务--Kubelet，并且能够
被Master管理。在Node上运行的服务进程包括Kubelet、kube-proxy、docker daemon。  
查看node的详细信息:
```$xslt2
kubectl describe node node_name
```
#### Node的管理
   Node通常是物理机、虚拟机或者云服务商提供的资源，并不是由Kubernetes创建的，我们说创建
的是一个Node是指在系统内部创建一个Node对象，然后对其进行一系列健康检查
## Kubernetes集群安装
### kubeadm
kubeadm一个工具，用于快速搭建kubernetes集群，目前应该是比较方便和推荐的，简单易用  
kubeadm是Kubernetes 1.4开始新增的特性  
kubeadm init 以及 kubeadm join 这两个命令可以快速创建 kubernetes 集群
### minikube
一般用于本地开发、测试和学习，不能用于生产环境  
minikube是一个工具，minikube快速搭建一个运行在本地的单节点的Kubernetes
### 二进制包
在官网下载相关的组件的二进制包，上面的两个是工具，可以快速搭建集群，也就是相
当于用程序脚本帮我们装好了集群，前两者属于自动部署，简化部署操作，自动部署屏
蔽了很多细节，使得对各个模块感知很少，遇到问题很难排查，如果手动安装，对
kubernetes理解也会更全面。  
目前生产环境的主流搭建方式，已在生产环境验证，kubeadm也可以搭建生产环境，不
过kubeadm应该还没有被大规模在生产环境验证
### yum命令安装
```$xslt2
# 安装etcd和kubernetes
yum install -y etcd kubernetes
# 服务启动
systemctl start etcd
systemctl start docker
systemctl start kube-apiserver
systemctl start kube-controller-manager
systemctl start kube-scheduler
systemctl start kubelet
systemctl start kube-proxy
```
