# Kubernetes Service
## 为什么需要Service
Kubernetes Pod是有生命周期的，它们可以被创建，也可以被销毁，然而一旦被销毁生命就永远结束。
通过ReplicationController能够动态地创建和销毁Pod（例如，需要进行扩缩容，或者执行 滚动升
级）。每个Pod都会获取它自己的IP地址，即使这些IP地址不总是稳定可依赖的。这会导致一个问题：
在Kubernete 集群中，如果一组Pod（称为backend）为其它Pod （称为frontend）提供服务，
那么那些frontend该如何发现，并连接到这组Pod中的哪些backend呢？
### Service引入
Kubernetes Service定义了这样一种抽象：一个Pod的逻辑分组，一种可以访问它们的策略，通常称为微服务。
这一组Pod能够被Service访问到，通常是通过Label Selector（查看下面了解，为什么可能需要没有selector
的Service实现的。  
举个例子，考虑一个图片处理backend，它运行了3个副本。这些副本是可互换的。frontend不需要关心它们调用了
哪个backend副本。然而组成这一组backend程序的Pod实际上可能会发生变化，frontend客户端不应该也没必要
知道，而且也不需要跟踪这一组backend的状态。Service定义的抽象能够解耦这种关联。    
对Kubernetes集群中的应用，Kubernetes提供了简单的Endpoints API，只要Service中的一组Pod发生变更，
应用程序就会被更新。对非Kubernetes集群中的应用，Kubernetes提供了基于VIP的网桥的方式访问Service，
再由Service重定向到backend Pod。
## Service定义
一个Service在Kubernetes中是一个REST对象，和Pod类似。像所有的REST对象一样，Service定义可以基于
POST方式，请求apiserver创建新的实例。
文件定义可以参看[template-server.yaml](template-service.yaml)
### 没有Selector的Service
Servcie抽象了该如何访问Kubernetes Pod，但也能够抽象其它类型的backend，例如：
* 希望在生产环境中使用外部的数据库集群，但测试环境使用自己的数据库。
* 希望服务指向另一个Namespace中或其它集群中的服务。
* 正在将工作负载转移到Kubernetes集群，和运行在Kubernetes集群之外的backend。
由于这个Service没有selector，就不会创建相关的Endpoints对象。可以手动将Service
映射到指定的Endpoints：
```$xslt2
kind: Endpoints
apiVersion: v1
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 1.2.3.4
    ports:
      - port: 9376
```
## VIP和Service代理
在Kubernetes集群中，每个Node运行一个kube-proxy进程。kube-proxy负责为Service实现了一种VIP
（虚拟 IP）的形式，而不是ExternalName的形式。在Kubernetes v1.0版本，代理完全在userspace。
在Kubernetes v1.1版本，新增了iptables代理，但并不是默认的运行模式。从Kubernetes v1.2起，
默认就是iptables代理。    
在Kubernetes v1.0版本，Service是“4层”（TCP/UDP over IP）概念。在Kubernetes v1.1版本，
新增了Ingress API（beta 版），用来表示“7层”（HTTP）服务。
### userspace代理模式
这种模式，kube-proxy会监视Kubernetes master对Service对象和Endpoints对象的添加和移除。 
对每个Service，它会在本地Node上打开一个端口（随机选择）。任何连接到“代理端口”的请求，都会
被代理到Service的backend Pods中的某个上面（如 Endpoints 所报告的一样）。使用哪个backend Pod，
是基于Service的SessionAffinity来确定的。最后，它安装iptables规则，捕获到达该Service的clusterIP
（是虚拟 IP）和Port的请求，并重定向到代理端口，代理端口再代理请求到backend Pod。  
网络返回的结果是，任何到达Service的IP:Port的请求，都会被代理到一个合适的backend，不需要客户端知道
关于Kubernetes、Service、或Pod的任何信息。  
默认的策略是，通过round-robin算法来选择backend Pod。实现基于客户端IP的会话亲和性，可以通过设置
service.spec.sessionAffinity的值为"ClientIP"（默认值为 "None"）。
### iptables代理模式
这种模式，kube-proxy会监视Kubernetes master对Service对象和Endpoints对象的添加和移除。对每个
Service，它会安装iptables规则，从而捕获到达该Service的clusterIP（虚拟 IP）和端口的请求，进而
将请求重定向到Service的一组backend中的某个上面。对于每个Endpoints对象，它也会安装iptables规则，
这个规则会选择一个backend Pod。   
默认的策略是，随机选择一个backend。实现基于客户端IP的会话亲和性，可以将service.spec.sessionAffinity
的值设置为 "ClientIP"（默认值为"None"）。  
和userspace代理类似，网络返回的结果是，任何到达Service的IP:Port的请求，都会被代理到一个合适的
backend，不需要客户端知道关于Kubernetes、Service、或Pod的任何信息。这应该比userspace代理更快、更可靠。
然而，不像userspace代理，如果初始选择的Pod没有响应，iptables代理能够自动地重试另一个Pod，所以它需要依赖
readiness probes。
## 多端口Service
很多Service需要暴露多个端口。对于这种情况，Kubernetes支持在Service对象中定义多个端口。当使用多个
端口时，必须给出所有的端口的名称，这样Endpoint就不会产生歧义。
## 选择自己的IP地址
在Service创建的请求中，可以通过设置spec.clusterIP字段来指定自己的集群IP地址。 比如，希望替换一个
已经已存在的DNS条目，或者遗留系统已经配置了一个固定的IP且很难重新配置。用户选择的IP地址必须合法，并且
这个IP地址在service-cluster-ip-range CIDR范围内，这对API Server来说是通过一个标识来指定的。 如
果IP地址不合法，API Server会返回HTTP状态码422，表示值不合法。  
### 为什么不使用round-robin DNS
一个不时出现的问题是，为什么我们都使用VIP的方式，而不使用标准的round-robin DNS，有如下几个原因：
* 长久以来，DNS库都没能认真对待DNS TTL、缓存域名查询结果
* 很多应用只查询一次DNS并缓存了结果
* 就算应用和库能够正确查询解析，每个客户端反复重解析造成的负载也是非常难以管理的
## 服务发现
Kubernetes支持2种基本的服务发现模式 —— 环境变量和DNS。
### 环境变量
当运行在Node上，kubelet会为每个活跃的Service添加一组环境变量。它同时支持Docker links
兼容变量（查看 makeLinkVariables）、简单的{SVCNAME}_SERVICE_HOST和
{SVCNAME}_SERVICE_PORT 变量，这里Service的名称需大写，横线被转换成下划线。   
举个例子，一个名称为"redis-master"的Service暴露了TCP端口6379，同时给它分配了Cluster IP
地址 10.0.0.11，这个Service生成了如下环境变量：
```$xslt2
REDIS_MASTER_SERVICE_HOST=10.0.0.11
REDIS_MASTER_SERVICE_PORT=6379
REDIS_MASTER_PORT=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP=tcp://10.0.0.11:6379
REDIS_MASTER_PORT_6379_TCP_PROTO=tcp
REDIS_MASTER_PORT_6379_TCP_PORT=6379
REDIS_MASTER_PORT_6379_TCP_ADDR=10.0.0.11
```
注意：意味着需要有顺序的要求。Pod想要访问的任何Service必须在Pod自己之前被创建，
否则这些环境变量就不会被赋值。DNS并没有这个限制。
### DNS（推荐）
一个可选（尽管强烈推荐）集群插件是DNS服务器。DNS服务器监视着创建新Service的
Kubernetes API，从而为每一个Service创建一组DNS记录。如果整个集群的DNS一直
被启用，那么所有的Pod应该能够自动对Service进行名称解析。    
例如，有一个名称为"my-service"的Service，它在Kubernetes集群中名为"my-ns"
的Namespace中，为"my-service.my-ns"创建了一条DNS记录。在名称为"my-ns"的
Namespace中的Pod应该能够简单地通过名称查询找到"my-service"。在另一个Namespace
中的Pod必须限定名称为"my-service.my-ns"。这些名称查询的结果是Cluster IP。  
Kubernetes也支持对端口名称DNS SRV（Service）记录。如果名称为"my-service.my-ns"
的Service有一个名为"http"的TCP端口，可以对"_http._tcp.my-service.my-ns"执行
DNS SRV查询，得到"http"的端口号。  
Kubernetes DNS服务器是唯一的一种能够访问ExternalName类型的Service 的方式。
## Headless Service
有时不需要或不想要负载均衡，以及单独的Service IP。遇到这种情况，可以通过指定Cluster
IP（spec.clusterIP）的值为"None"来创建Headless Service。  
这个选项允许开发人员自由寻找他们自己的方式，从而降低与Kubernetes系统的耦合性。应用仍然
可以使用一种自注册的模式和适配器，对其它需要发现机制的系统能够很容易地基于这个API来构建。  
对这类Service并不会分配Cluster IP，kube-proxy不会处理它们，而且平台也不会为它们进行负
载均衡和路由。DNS如何实现自动配置，依赖于Service是否定义了selector。
### 配置Selector
对定义了selector的Headless Service，Endpoint控制器在API中创建了Endpoints记录，并且
修改DNS配置返回A记录（地址），通过这个地址直接到达Service的后端Pod上。
### 不配置Selector
对没有定义selector的Headless Service，Endpoint控制器不会创建Endpoints记录。
然而DNS系统会查找和配置，无论是：  
* ExternalName类型Service的CNAME记录
* 记录：与Service共享一个名称的任何Endpoints，以及所有其它类型
## 发布服务--服务类型
对一些应用（如Frontend）的某些部分，可能希望通过外部（Kubernetes集群外部）IP地址暴露
Service。   
Kubernetes ServiceTypes允许指定一个需要的类型的Service，默认是ClusterIP类型。  
Type的取值以及行为如下：  
* ClusterIP：通过集群的内部IP暴露服务，选择该值，服务只能够在集群内部可以访问，这也是默认的ServiceType。
* NodePort：通过每个Node上的IP和静态端口（NodePort）暴露服务。NodePort服务会路由到ClusterIP服务，这个
  ClusterIP服务会自动创建。通过请求<NodeIP>:<NodePort>，可以从集群的外部访问一个NodePort服务。
* LoadBalancer：使用云提供商的负载局衡器，可以向外部暴露服务。外部的负载均衡器可以路由到NodePort服务和
  ClusterIP服务。
* ExternalName：通过返回CNAME和它的值，可以将服务映射到externalName字段的内容（例如，foo.bar.example.com）。
  没有任何类型代理被创建，这只有Kubernetes 1.7或更高版本的kube-dns才支持。
### NodePort类型
如果设置type的值为"NodePort"，Kubernetes master将从给定的配置范围内（默认：30000-32767）分配端口，每个Node
将从该端口（每个Node上的同一端口）代理到Service。该端口将通过Service的spec.ports[*].nodePort字段被指定。  
如果需要指定的端口号，可以配置nodePort的值，系统将分配这个端口，否则调用API将会失败（比如，需要关心端口冲突的可能性）。
这可以让开发人员自由地安装他们自己的负载均衡器，并配置Kubernetes不能完全支持的环境参数，或者直接暴露一个或多个Node的IP地址。
需要注意的是，Service将能够通过 <NodeIP>:spec.ports[*].nodePort和spec.clusterIp:spec.ports[*].port而对外可见。  
### LoadBalancer类型
使用支持外部负载均衡器的云提供商的服务，设置type的值为"LoadBalancer"，将为Service提供负载均衡器。负载均衡器是异步创建的，
关于被提供的负载均衡器的信息将会通过Service的status.loadBalancer字段被发布出去。  
```$xslt2
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
      nodePort: 30061
  clusterIP: 10.0.171.239
  loadBalancerIP: 78.11.24.19
  type: LoadBalancer
status:
  loadBalancer:
    ingress:
      - ip: 146.148.47.155
```
来自外部负载均衡器的流量将直接打到backend Pod上，不过实际它们是如何工作的，这要依赖于云提供商。在这些情况下，将根据用户设置的
loadBalancerIP来创建负载均衡器。某些云提供商允许设置loadBalancerIP。如果没有设置loadBalancerIP，将会给负载均衡器指派一个
临时IP。 如果设置了loadBalancerIP，但云提供商并不支持这种特性，那么设置的loadBalancerIP值将会被忽略掉。
### AWS内部负载均衡器
在混合云环境中，有时从虚拟私有云（VPC）环境中的服务路由流量是非常有必要的。可以通过在Service中增加annotation
来实现，如下所示：  
```$xslt2
[...]  
metadata: 
    name: my-service
    annotations: 
        service.beta.kubernetes.io/aws-load-balancer-internal: 0.0.0.0/0  
[...]  
```
在水平分割的DNS环境中，需要两个Service来将外部和内部的流量路由到Endpoint上。
### AWS SSL支持
对运行在AWS上部分支持SSL的集群，从1.3版本开始，可以为LoadBalancer类型的Service增加两个annotation：   
```$xslt2
metadata:
      name: my-service
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
```
第一个annotation指定了使用的证书。它可以是第三方发行商发行的证书，这个证书或者被上传到IAM，或者由AWS的证书管理器创建。  
```$xslt2
metadata:
      name: my-service
      annotations:
         service.beta.kubernetes.io/aws-load-balancer-backend-protocol: (https|http|ssl|tcp)
```
第二个annotation指定了Pod使用的协议。对于HTTPS和SSL，ELB将期望该Pod基于加密的连接来认证自身。  
HTTP和HTTPS将选择7层代理：ELB将中断与用户的连接，当转发请求时，会解析Header信息并添加上用户的
IP地址（Pod将只能在连接的另一端看到该IP地址）。  
TCP和SSL将选择4层代理：ELB将转发流量，并不修改Header信息。  
### 外部IP
如果外部的IP路由到集群中一个或多个Node上，Kubernetes Service会被暴露给这些externalIPs。通过外部IP
（作为目的IP地址）进入到集群，打到Service的端口上的流量，将会被路由到Service的Endpoint上。externalIPs 
不会被Kubernetes管理，它属于集群管理员的职责范畴。