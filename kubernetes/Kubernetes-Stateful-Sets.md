# Kubernetes StatefulSets
StatefulSet（有状态系统服务设计）是用来管理有状态服务应用的工作负载API对象。
StatefulSet是用来管理Deployment和扩展一组Pod，并且能为这些Pod提供序号和
唯一性保证。  
和Deployment相同的是，StatefulSet管理了一组基于相同容器定义的Pod，但和
Deploymnet不同的是，StatefulSet为它们的每个Pod维护了固定的id，这些Pod基于
相同的容器定义创建，但是不能互相替换。无论怎么调度，每个Pod都有一个永久不变的ID。  
StatefulSet和其他控制器使用相同的工作模式。你在StatefulSet对象中定义你期望的
状态，然后StatefulSet的控制器就会通过各种更新来达到那种你想要的状态。
## StatefulSet使用场景
StatefulSet对于满足以下一个或多个的需求的应用程序很有价值。
* 稳定的、唯一的网络标识符
* 稳定的、持久化存储
* 有序的、优雅的部署和缩放
* 有序的、自动的滚动更新  
在上面，稳定意味着Pod调度或重调度的整个过程是有持久性的。如果应用程序不需要任何
稳定的标识符或有序的部署、删除或伸缩，则应该使用由一组无状态的副本控制器提供的工
作负载来部署应用程序，比如Deployment或者ReplicaSet可能更适用于您的无状态应用
部署需要。
## StatefulSet限制
* 给定Pod的存储必须由PersistentVolume驱动基于所请求的storage class来提供，
  或者由管理员预先提供。
* 删除或者收缩StatefulSet并不会删除它关联的存储卷。这样做是为了保证数据安全，
  它通常比自动清除StatefulSet所有相关的资源更有价值。
* StatefulSet当前需要headless服务来负责Pod的网络标识。您需要负责创建此服务。
* 当删除StatefulSets时，StatefulSet不提供任何终止Pod的保证。为了实现
  StatefulSet中的Pod可以有序和优雅的终止，可以在删除之前将StatefulSet缩放为0。
* 在默认Pod管理策略(OrderedReady) 时使用滚动更新，可能进入需要人工干预才能修复
  的损坏状态
## Pod管理策略
* OrderedReady Pod Management是StatefulSets的默认行为。它实现了上述“部署/扩展”行为。
* Parallel Pod Management告诉StatefulSet控制器同时启动或终止所有Pod。