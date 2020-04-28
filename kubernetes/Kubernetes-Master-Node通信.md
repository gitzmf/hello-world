# Master-Node通信
Master和Kubernetes集群之间的通信路径。其目的是允许用户自定义安装
以增强网络配置，使集群可以在不受信任的网络中运行。
## Cluster->Master
从集群到Master节点的所有通信路径都在apiserver中终止。一个典型的
deployment，如果apiserver配置为监听远程连接上的HTTPS 443端口，
应启用一种或多种client authentication，特别是如果允许anonymous 
requests或service account tokens。  
Node节点应该配置为集群的公共根证书，以便安全地连接到apiserver。
希望连接到apiserver的Pod可以通过service account来实现，以便
Kubernetes在实例化时自动将公共根证书和有效的bearer token插入
到pod中，kubernetes service (在所有namespaces中)都配置了一个
虚拟IP地址，该IP地址由apiserver重定向(通过kube-proxy)到HTTPS。

Master组件通过非加密(未加密或认证)端口与集群apiserver通信。这个
端口通常只在Master主机的localhost接口上暴露。
## Master->Cluster
从Master（apiserver）到集群主要有两个通信路径。
1. 第一个是从apiserver到集群中每个节点上运行的kubelet进程
2. 第二个是通过apiserver的代理功能从apiserver到任何Node，Pod，Service
### apiserver->kubelet
从apiserver到kubelet的连接用于获取Pod日志，通过kubectl来运行Pod，并使用kubectl
的端口转发功能，这些链接在kubelet的https终端终止。  
默认情况下apiserver不会验证kubelet的服务证书，这会使连接不受保护。要验证此连接，使
用--kubelet-certificate-authority flag为apiserver提供根证书包，以验证kubelet
的服务证书。  
如果不能实现，那么请在apiserver和kubelet之间使用SSH tunneling。  
最后，应该启用Kubelet认证或授权来保护Kubelet API。
### apiserver->node，Pod，Service
从apiserver到node，pod，service的连接默认为http连接，因此不需要进行认证加密。也可
以通过https的安全连接，但是他们不会验证https端口提供的安全证书，也不会提供客户端凭据
因此连接将被加密但不会提供任何诚信的保证。这些连接不可以在不受信任/或公共网络上运行。
### SSH tunneling
Google Container Engine使用SSH tunnels来保护Master->集群通信路径，SSH tunnel
能够使Node、Pod或Service发送的流量不会暴露在集群外部。