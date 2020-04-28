# Kubernetes Replication Controller
注意：建议使用Deployment配置ReplicaSet方式控制副本数量
ReplicationController（简称RC）是确保用户定义的副本数量保持不变的。
## ReplicationController工作原理
在用户定义的范围内，如果Pod增多，则ReplicationController会终止额外的Pod，
如果Pod减少，则会创建新的Pod，始终保持在定义的范围。例如：RC会在Pod维护
（比如内核升级）后会创建新的Pod。
* ReplicationController会替换由于某些原因而被删除或终止的pod，例如在节点
  故障或中断节点维护（例如内核升级）的情况下。因此，即使应用只需要一个pod，我们也建议使用ReplicationController。
* RC跨多个Node节点监视多个pod。
## ReplicationController实例
1. 配置文件参看[template-rc.yaml](./template-rc.yaml)
2. 根据配置文件创建ReplicationController
   ```$xslt2
   kubectl create -f template-rc.yaml
   ```
3. 检查ReplicationController状态
   ```$xslt2
   # name为template-rc.yaml中metadata.name的值
   kubectl describe replicationcontrollers/name
   ```
4. 列出属于ReplicationController的所有Pod
   ```$xslt2
   pods = $(kubectl get pods --selector=app=nginx --output=jsonpath={.item..metadata.name})
   echo pods   
   ```
5. 删除ReplicationController及其Pods
   ```$xslt2
   kubectl delete replicationcontrollers --selector=app=nginx
   # 使用配置文件删除
   kubetl delete -f template-rc.yaml
   ```
注意：当时用RestAPI或客户端库删除的时候，需要明确执行步骤
* 将副本缩放为0，然后等待Pod删除
* 然后删除ReplicationController
6. 只删除ReplicationController
   ```$xslt
   # 为kubectl delete指定--cascade=false选项
    kubectl delete replicationcontrollers --selector=app=nginx  --cascade=false
   ```
注意：使用RestAPI或者客户端删除的时候，只需删除ReplicationController即可
删除ReplicationController对象后，可以创建一个新的ReplicationController来替代
它，只要.spec.selector相匹配，就会采用旧的Pod
7. ReplicationController隔离Pod
 可以通过更改标签来从ReplicationController的目标集中删除Pod。
## ReplicationController使用场景
1. 重新调度
   无论您想要继续运行1个pod还是1000个Pod，一个ReplicationController都将确保存在指定数量的pod，
   即使在节点故障或pod终止(例如，由于另一个控制代理的操作)的情况下也是如此。
2. 扩容
   通过简单地更新replicas字段，ReplicationController可以方便地横向扩容或缩容副本的数量，或手动
   或通过自动缩放控制代理
3. 滚动更新
   ReplicationController的设计目的是通过逐个替换pod以方便滚动更新服务。可以参看kubectl rolling-update来实现。
4. 多版本跟踪
   除了在滚动更新过程中运行应用程序的多个版本之外，通常还会使用多个版本跟踪来长时间，甚至持续运行
   多个版本。这些跟踪将根据标签加以区分。
5. 和Service一起使用ReplicationController
   多个ReplicationController可以位于一个服务的后面，例如，一部分流量流向旧版本，一部分流量流向新版本。
## ReplicationController替代方法
1. ReplicaSet
   ReplicaSet是下一代的ReplicationController，它支持新的基于集合的标签选择器，主要被Deployment
   用作编排Pod的创建、删除以及更新机制。  
   我们推荐使用Deployment而不是直接使用 ReplicaSet，除非您需要自定义更新编排或根本不需要更新。
2. Deployment（推荐）
   Deployment是一种更高级的API对象，它以类似于kubectl rolling-update的方式更新其底层的ReplicaSet和
   Pod。如果想使用这种滚动更新的功能，推荐使用Deployment。
  
