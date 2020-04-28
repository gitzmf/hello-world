# Kubernetes组件概述
一个Kubernetes集群包含集群由一组被称作节点的机器组成。这些节点上运行Kubernetes所管理的容器化应用。集群具有
至少一个工作节点和至少一个主节点。工作节点托管作为应用程序组件的Pod。主节点管理集群中的工作节点和Pod。多个主节
点用于为集群提供故障转移和高可用性。
本文档概述了交付正常运行的Kubernetes集群所需的各种组件。
![Kubernetes组件关联](./images/components-of-kubernetes.png)
## Master组件（控制平面组件）
Master组件提供集群的控制管理中心，可以在集群中的任何节点运行，但是通常独立出一台机器运行所有Master节点。
### kube-apiserver
kube-apiserver用于暴露Kubernetes的API，任何资源请求和调用操作都是通过kube-apiserver提供的接口进行的。
### etcd
etcd是Kubernetes默认提供的存储系统，保存集群中的所有数据，使用时需要为etcd数据提供备份计划。
### kube-scheduler
主节点上的组件，该组件监视哪些已创建还没指定运行节点的Pod，并选择节点让Pod运行。
调度决策考虑的因素包括单个Pod和Pod集合的资源需求、硬件/软件/策略约束、亲和性和反亲和性规范、数据位置、工作负载
间的干扰和最后时限。
### kube-controller-manager
在主节点上运行控制器的组件，它们是后台处理常规任务的后台进程。逻辑上每个控制器是单独的一个进程，但为了降低复杂
性，它们都被编译到一个单独的二进制文件，并在一个进程中运行。  
主要包括以下控制器：
* Node Controller（节点控制器）：负责在节点出现故障时，进行通知和响应
* Replication Controller（副本控制器）：负责为系统中的每个副本控制器对象维护正确的Pod数量
* Endpoints Controller（端点控制器）：负责填充Endpoints对象（即加入Service和Pod对象）
* Service Account & Token Controller（服务账户和令牌控制）：为新的命名空间创建默认账户和API访问令牌
### cloud-controller-manager（云控制器管理器）
云控制器管理器负责与底层云提供商的平台交互。云控制器管理器是Kubernetes版本1.6中引入的。
云控制器管理器仅运行云提供商特定的（controller loops）控制器循环。可以通过将--cloud-provider flag设
置为external启动kube-controller-manager，来禁用控制器循环。  
主要包括以下控制器：  
* Node Controller（节点控制器）
* Route Controlelr（路由控制器）
* Service Controller（Service控制器）
* Volume Controller（卷控制器）
## Node组件
节点组件在每个节点上运行，维护运行的Pod并提供Kubernetes运行环境。
### kubelet
一个集群中每个节点运行的代理，保证容器都运行在Pod中，负责监视已分配给节点的Pod。

### kube-proxy
kube-proxy是集群中每个节点运行的网络代理，通过在主机上维护网络规则并执行连接转发来实现Kubernetes服务抽
象。这些网络规则允许从集群内部或外部的网络会话与Pod进行网络通信。