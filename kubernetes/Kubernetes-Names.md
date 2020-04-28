# Names
Kubernetes REST API中的所有对象都用Name和UID来明确地标识。  
* Name: 集群中的每一个对象都有一个名称来确保在同类资源中的唯一性  
* UIDs: 每个Kubernetes对象也有一个UID在确保在整个集群中的唯一性   
比如，在同一个namespace中只能命名一个名为 myapp-1234 的 Pod， 
但是可以命名一个 Pod 和一个 Deployment 同为 myapp-1234。   
对于非唯一用户提供的属性，Kubernetes提供labels和annotations。
## Name
一个对象同一时间内只能拥有单个Name，如果对象被删除，可以使用相同的Name
创建新的对象。Name用于在资源URL中引用对象
## UIDs
UIDs是由Kubernetes生成的，在Kubernetes集群的整个生命周期中创建的每
个对象都有不同的UID（即它们在空间和时间上是唯一的）
