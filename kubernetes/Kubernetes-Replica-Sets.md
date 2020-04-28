# Kubernetes Replica Sets
ReplicaSet（RS）是ReplicationController（RC）的升级版本，它们唯一的区别就是
对于选择器的支持。ReplicaSet支持基于集合的标签选择器，ReplicationController
仅支持相等的标签选择。
## 如何使用ReplicaSet
大多数kubectl支持Replication Controller命令的也支持ReplicaSets。rolling-update
命令除外，如果要使用rolling-update，请使用Deployments来实现。  
虽然ReplicaSets可以独立使用，但它主要被Deployments用作pod机制的创建、删除和更新。
当使用Deployment时，你不必担心创建pod的ReplicaSets，因为可以通过Deployment实现管理
ReplicaSets。
## 何时使用ReplicaSet
ReplicaSet能确保运行指定数量的pod。然而，Deployment 是一个更高层次的概念，它能管理
ReplicaSets，并提供对pod的更新等功能。因此，我们建议你使用Deployment来管理ReplicaSets，
除非你需要自定义更新编排。  
这意味着你可能永远不需要操作ReplicaSet对象，而是使用Deployment替代管理。
## ReplicaSet实例
1. 配置文件参看模板[template-rs.yaml](./template-rs.yaml)
2. 创建定义的ReplicaSer以及管理Pod
   ```$xslt2
   kubectl create -f template-rs.yaml
   ```
3. 检查ReplicaSet的状态
   ```$xslt2
   # name为template-rs.yaml中metadata.name的值
   kubectl describe rs/name
   ```
## ReplicaSet在HPA（Pod水平自动伸缩）的使用
Pod水平自动伸缩（Horizontal Pod Autoscaler）特性，可以基于CPU利用率自动伸缩
replication controller、deployment和 replica set中的pod数量，（除了CPU
利用率）也可以基于其他应程序提供的度量指标custom metrics。pod自动缩放不适用于
无法缩放的对象，比如DaemonSets。  
Pod 平自动伸缩特性由Kubernetes API资源和控制器实现。资源决定了控制器的行为。
控制器会周期性的获取平均CPU利用率，并与目标值相比较后来调整replication controller
或deployment中的副本数量。
   
