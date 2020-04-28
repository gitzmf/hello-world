# Kubernete Annotations
Annotations可以将任何非标识metadata附加到对象，客户端可以检测到该
metadata
## 将metadata附加到对象
可以通过labels或annotations将元数据附加到Kubernetes对象
* labels可以选择对象并查找某些满足对象的集合
* Annotations不用于标识和选择对象。Annotations中的元数据可以是
  small 或large，structured 或unstructured，并且可以包括标签
  不允许使用的字符  
注意：Annotations不会被Kubernetes直接使用，其主要目的是方便用户阅读查找。