# Namespaces（命名空间）
Namespace是对一组资源和对象的抽象集合，比如可以用来将系统内部的对象
划分为不同的项目组或用户组。常见的pods, services, replication 
controllers和deployments等都是属于某一个namespace的（默认是
default），而node, persistentVolumes等则不属于任何namespace。
Namespace常用来隔离不同的用户，比如Kubernetes自带的服务一般运行在
kube-system namespace中。  
命名空间名称满足正则表达式\[a-z0-9]([-a-z0-9]*[a-z0-9])?,最大长度为63位
## Namespaces的使用
Namespace的创建
```$xslt2
## 通过命令行直接创建
# 创建名称为test的命名空间
kubectl create namespace test
## 通过文件创建命名空间
cat test-namespace.yaml
    apiVersion: v1
    kind: Namespace
    metadata:
       name: test
kubectl create -f test-namepace.yaml       
```
Namespace的删除
```$xslt2
kubectl delete namespaces test
```
注意： 
1. 删除一个namespace，也会自动删除属于namespace的所有资源
2. default和kube-system命名空间不可删除
3. PersistentVolumes（持久化卷）不属于任何namespace，但PersistentVolumeClaim是属于某个特定的namespace，PersistentVolumeClaim（简称PVC）是用户存储的请求
4. Events是否属于namespace，看是否产生了events对象
Namespacce的查看
```$xslt2
kubectl get namespaces
```
为请求设置命名空间
```$xslt2
kubectl --namespace=test get pods
kubectl --namespace=test run nginx --image=nginx
```
永久保存Namespace到context中
```$xslt2
kubectl config set-context --current --namespace=test
# 验证是否保存成功
kubectl config view | grep namespace:
```