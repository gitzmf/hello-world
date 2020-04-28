# Kubernetes对象概述
Kubernetes对象是Kubernetes系统中的持久实体。Kubernetes使用这些实体来表示集群的
状态。具体来说，他们可以描述：  
* 容器化应用正在运行(以及在哪些节点上)
* 这些应用可用的资源
* 关于这些应用如何运行的策略，如重新策略，升级和容错  

Kubernetes对象是“record of intent”，一旦创建了对象，Kubernetes系统会确保对象
存在。通过创建对象，可以有效地告诉Kubernetes系统你希望集群的工作负载是什么样的。
要使用Kubernetes对象（无论是创建，修改还是删除），都需要使用Kubernetes API。例如
，当使用kubectl命令管理工具时，CLI会为通过提供Kubernetes API调用。你也可以直接在
自己的程序中使用Kubernetes API，Kubernetes提供一个golang客户端库 （其他语言库正
在开发中-如Python）。

## 对象（Object）规范和状态
每个Kubernetes对象都包含两个嵌套对象字段，用于管理Object的配置：Object Spec和
Object Status。
* Spec描述了对象所需的状态 - 希望Object具有的特性，
* Status描述了对象的实际状态，并由Kubernetes系统提供和更新。

例如，通过Kubernetes Deployment 来表示在集群上运行的应用的对象。创建Deployment
时，可以设置Deployment Spec，来指定要运行应用的三个副本。Kubernetes系统将读取
Deployment Spec，并启动你想要的三个应用实例 - 来更新状态以符合之前设置的Spec。
如果这些实例中有任何一个失败（状态更改），Kuberentes系统将响应Spec和当前状态之间差
异来调整，这种情况下，将会开始替代实例。

## 描述Kubernetes对象
在Kubernetes中创建对象时，必须提供描述其所需Status的对象Spec，以及关于对象（如name）
的一些基本信息。当使用Kubernetes API创建对象（直接或通过kubectl）时，该API请求必须
将该信息作为JSON包含在请求body中。通常，可以将信息提供给kubectl *.yaml配置文件，在进行
API请求时，kubectl将信息转换为JSON。  
创建对象的yaml文件必填字段信息：
* apiVersion - 创建对象的Kubernetes API 版本
* kind - 要创建什么样的对象？
* metadata- 具有唯一标示对象的数据，包括 name（字符串）、UID和Namespace（可选项）
* Spec对象字段，对象Spec的精确格式（对于每个Kubernetes 对象都是不同的），以及容器内
  嵌套的特定于该对象的字段。Kubernetes API reference可以查找所有可创建Kubernetes对象的Spec格式。