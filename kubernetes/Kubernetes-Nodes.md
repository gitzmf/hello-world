# Kubernetes Nodes
Node是Kubernetes上的工作节点，最早称为minion。一个node上有运行Pod的
必要服务，并由Master组件直接进行管理，Node节点上的服务包括kubelet、
Docker、kube-proxy
## Node status
节点的状态信息包含：  
* Addresses
  这个字段的使用取决于云服务商或者裸机的配置  
  HostName：可以通过kubelet的--hostname-override参数覆盖
  ExternallIp：可以被集群外部路由到的IP
  InternallIp：只能在集群内部进行路由的节点的IP地址
* Condition
  Condition字段描述所有Running节点的状态  
   
  | Node Condition| 描述|  
  | ---- | ---- |
  | OutofDisk | True：如果节点上没有足够的可用空间来添加新的pod；否则为：False |
  | Ready | True：如果节点是健康的并准备好接收pod；False：如果节点不健康并且不接受pod；Unknown：如果节点控制器在过去40秒内没有收到node的状态报告。|
  | MemoryPressure | True：如果节点存储器上内存过低，否则为：False |
  | DiskPressure | True：如果磁盘存在压力，即磁盘容量过低，否则为：False |
  
* Capacity
  描述节点的可用资源，CPU，内存以及可以调度到节点上的最大Pod数
* Info
  节点的一些基础信息，如内核版本、Kubernetes版本、Docker版本、OS名称等