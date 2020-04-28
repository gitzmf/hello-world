# Kubernetes Volume
默认情况下容器中的磁盘文件是不支持持久化的，对于运行在容器中的应用来说
存在两个问题：
1. 当容器挂掉，kubelet将重启它时，文件将丢失
2. 当Pod运行多个容器，容器间需要共享文件时
## Kubernetes Volume与Docker Volume区别
1. Docker Volume只是磁盘中的一个目录，生命周期不受管理
2. Kubernetes Volume具有明确的生命周期-与Pod相同，Volume的生命周
   期比运行在Pod的任何容器都要持久，所以在容器启动的时候可以保存数据，
   当然当Pod删除时候，Volume也相应的消失。  
注意，Kubernetes支持许多类型的Volume，Pod可以同时使用任意类型/数量的Volume。
内部实现中，一个Volume只是一个目录，目录中可能有一些数据，pod的容器可以访问这些
数据。至于这个目录是如何产生的、支持它的介质、其中的数据内容是什么，这些都由使用的
特定Volume类型来决定。
要使用Volume，pod需要指定Volume的类型和内容（spec.volumes字段），和映射到容
器的位置（spec.containers.volumeMounts字段）。
## Volume类型
Kubernetes支持Volume类型有：
* emptyDir
* hostPath
* gcePersistentDisk
* awsElasticBlockStore
* nfs
* iscsi
* fc (fibre channel)
* flocker
* glusterfs
* rbd
* cephfs
* gitRepo
* secret
* persistentVolumeClaim
* downwardAPI
* projected
* azureFileVolume
* azureDisk
* vsphereVolume
* Quobyte
* PortworxVolume
* ScaleIO
* StorageOS
* local