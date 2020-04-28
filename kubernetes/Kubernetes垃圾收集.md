# Kubernetes垃圾收集
Kubernetes垃圾收集角色是删除指定的对象，这些对象曾经拥有但以后不会拥有Owner了。
## Owner和Dependent
一些Kubernetes对象是其他对象的Owner，比如：一个ReplicaSet是一组Pod的Owner。
具有Owner的对象被称为Owner的Dependent。每个Dependent对象都有一个指向其所属
对象的.metadata.ownerReferences字段。  
有时，Kubernetes会自动设置ownerReference的值。例如：当创建一个ReplicaSet时，
Kubernetes会自动设置ReplicaSet中每个Pod的ownerReference字段值。在1.6版本中
Kubernetes会自动为一些对象设置ownerReference的值，这些对象是由ReplicationController、
ReplicaSet、StatefulSet、DaemonSet和Deployment所创建或管理。
## 控制垃圾收集器删除Dependent
当删除对象时，可以指定是否该对象的Dependent也自动删除掉。自动删除Dependent也称为级联删除。
Kubernetes中有两种级联删除的模式：
* background模式
* foreground模式  
如果删除对象时，不自动删除它的Dependent，这些Dependent被称作是原对象的孤儿
### background模式删除
在background模式下删除，Kubernetes会立即删除Owner对象，然后垃圾收集器会在后台删除Dependent
### foreground模式删除
在foreground模式下删除，根对象首先进入删除中状态，在删除中，状态会有如下情况：
* 对象仍然可以通过REST API可见
* 会设置对象的deletionTimestamp字段
* 对象的metadata.finalizers字段包含了值“foregroundDeletion”
一旦被设置为“删除中”状态，垃圾收集器会删除对象的所有Dependent。垃圾收集器删除了所有“Blocking”
的Dependent（对象的ownerReference.blockOwnerDeletion=true）之后，它会删除Owner对象。  
注意，在 “foreground删除”模式下，Dependent只有通过ownerReference.blockOwnerDeletion才
能阻止删除Owner对象。在Kubernetes 1.7版本中将增加admission controller，基于Owner对象上的
删除权限来控制用户去设置blockOwnerDeletion的值为true，所以未授权的Dependent不能够延迟Owner
对象的删除。

如果一个对象的ownerReferences 字段被一个 Controller（例如 Deployment 或 ReplicaSet）设置，
blockOwnerDeletion 会被自动设置，没必要手动修改这个字段。
### 设置级联删除策略（Policy）
通过为Owner对象设置deleteOptions.propagationPolicy字段，可以控制级联删除策略。可能的取值
包括：“orphan”、“Foreground”或“Background”。
对很多Controller资源，包括ReplicationController、ReplicaSet、StatefulSet、DaemonSet和
Deployment，默认的垃圾收集策略是orphan。因此，除非指定其它的垃圾收集策略，否则所有Dependent对
象使用的都是orpha策略。
* background策略
  删除控制器之后，所管理的资源对象由GC删除
* foreground策略
  删除控制器之前，所管理的资源对象先进行删除
* orphan策略
  只删除控制器，不删除其所管理的资源对象