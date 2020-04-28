# Kubernetes Deployment
Deployment为Pod和ReplicaSet（ReplicationController）提供声明式更新。  
你只需要在 eployment中描述您想要的目标状态是什么，Deployment controller
就会帮您将Pod和ReplicaSet的实际状态改变到您的目标
状态。您可以定义一个全新的Deployment来创建ReplicaSet或者删除已有的Deployment
并创建一个新的来替换。

注意：您不该手动管理由Deployment 建的Replica Set，否则您就篡越了Deployment 
controller的职责！下文罗列了Deployment对象中已经覆盖了所有的用例。如果未有覆盖
您所有需要的用例，请直接在Kubernetes 的代码库中提issue。
典型的用例如下：
1. 使用Deployment来创建ReplicaSet。ReplicaSet在后台创建pod。检查启动状态，看
   它是成功还是失败。
2. 通过更新Deployment的PodTemplateSpec字段来声明Pod的新状态。这会创建一个新的
   ReplicaSet，Deployment会按照控制的速率将pod从旧的ReplicaSet移动到新的ReplicaSet中。
3. 如果当前状态不稳定，回滚到之前的Deployment revision。每次回滚都会更新Deployment的revision。
4. 扩容Deployment以满足更高的负载。
5. 暂停Deployment来应用PodTemplateSpec的多个修复，然后恢复上线。
6. 根据Deployment的状态判断上线是否卡住了。
7. 清除旧的不必要的ReplicaSet。
## 创建Deployment
1. 配置template-deployment.yaml文件
   ```$xslt2
   kubectl create -f template-deployment.yaml --record=true
   ```
2. 查看创建的Deployment
   ```$xslt2
   # name为template-deployment.yaml中定义的metadata.name
   kubectl get deployments/name
   ```
3. 查看创建的ReplicaSet、Pod
   ```$xslt2
   # ReplicaSet
   kubectl get rs
   # Pod
   kubectl get pods --show-labels
   ```
注意：您必须在Deployment中的selector指定正确的pod template
label（在该示例中是 app=nginx），不要跟其他的controller的
selector中指定的pod template label搞混了（包括 Deployment、
Replica Set、Replication Controller等）。Kubernetes本身并
不会阻止您任意指定pod template label ，但是如果您真的这么做了，
这些controller之间会相互打架，并可能导致不正确的行为。
### pod-template-hash label
注意：这个label不是用户指定的！  
注意上面示例输出中的pod label里的pod-template-hash label。当
Deployment创建或者接管ReplicaSet时，Deployment controller会
自动为Pod添加pod-template-hash label。这样做的目的是防止Deployment
的子ReplicaSet的pod名字重复。通过将ReplicaSet的PodTemplate进行哈希
散列，使用生成的哈希值作为label的值，并添加到ReplicaSet selector里、 
pod template label和ReplicaSet管理中的Pod上。
## 更新Deployment
注意：Deployment的rollout当且仅当Deployment的pod template
（例如.spec.template）中的label更新或者镜像更改时被触发。其他更新，
例如扩容Deployment不会触发rollout。
例如： nginx pod使用nginx:1.9.1的镜像来代替原来的nginx:1.7.9的镜像  
1. 镜像改变
    ```$xslt2
    # 通过命令实现
    kubectl set image deployment/name nginx=nginx:1.7.9
    # 通过编辑文件实现
    kubectl edit deployment/name
    ```
2. 查看rollout状态
    ```$xslt2
    kubectl rollout status deployment/name
    ```
3. 查看Deployment，会发现UP-TO-DATE的replica的数目已经达到了配置中要求的数目
    ```$xslt2
    kubectl get deployment/name
    ```   
4. 查看那ReplicaSet可以看到Deployment更新了Pod，通过创建一个新的ReplicaSet
   并扩容了3个replica，同时将原来的ReplicaSet缩容到了0个replica。
   ```$xslt2
   kubectl get rs
   ```     
5. 此时看的Pod也是最新的Pod
   ```$xslt2
   kubectl get pods
   ```
6. 查看Deployment的滚动更新详情
   ```$xslt2
   kubectl describe deployments
   ```   
### Rollover（多个rollout并行）
例如，假如您创建了一个有5个niginx:1.7.9 replica的Deployment，但是当还只
有3个nginx:1.7.9的replica创建出来的时候您就开始更新含有5个nginx:1.9.1 
replica的Deployment。在这种情况下，Deployment会立即杀掉已创建的3个
nginx:1.7.9的Pod，并开始创建nginx:1.9.1的Pod。它不会等到所有的5个
nginx:1.7.9的Pod都创建完成后才开始改变航道。
### lable selector更新
我们通常不鼓励更新label selector，我们建议实现规划好您的selector。
任何情况下，只要您想要执行label selector的更新，请一定要谨慎并确认
您已经预料到所有可能因此导致的后果。  
* 增添selector需要同时在Deployment的spec中更新新的label，否则将返回校验错误。
  此更改是不可覆盖的，这意味着新的selector不会选择使用旧selector创建的ReplicaSet
  和Pod，从而导致所有旧版本的ReplicaSet都被丢弃，并创建新的ReplicaSet。
* 更新selector，即更改selector key的当前值，将导致跟增添selector同样的后果。
* 删除selector，即删除Deployment selector中的已有的key，不需要对Pod template
  label做任何更改，现有的ReplicaSet也不会成为孤儿，但是请注意，删除的label仍然存在于
  现有的Pod和ReplicaSet中。
## 回退Deployment
有时候您可能想回退一个Deployment，例如，当Deployment不稳定时，比如一直 rash looping。
默认情况下，kubernetes会在系统中保存前两次的Deployment的rollout历史记录，以便您可以随
时回退（您可以修改revision history limit来更改保存的revision数）。
注意： 只要Deployment的rollout被触发就会创建一个revision。也就是说当且仅当Deployment
的Pod template（如.spec.template）被更改，例如更新template中的label和容器镜像时，就
会创建出一个新的revision。
实例：更新Deployment的时候犯了一个拼写错误，将镜像的名字写成了nginx:1.91，而正确的名字应该是nginx:1.9.1：
1. 更新镜像
    ```$xslt2
    kubectl set image deployment/name nginx=nginx:1.91
    ```
2. 查看rollout会发现被卡住，然后ctrl+c终止上面的rollout状态监控
   ```$xslt2
   kubectl rollout status deployment/name
   ```    
3. 查看ReplicaSet，发现是两个
   ```$xslt2
   kubectl get rs
   ```   
4. 查看pods，会发现新的ReplicaSet新创建的Pod处于ImagePullBackOff状态，循环拉取镜像。
   ```$xslt2
   kubectl get pods
   ```
注意，Deployment controller会自动停止坏的rollout，并停止扩容新的ReplicaSet。
为了修复这个问题，我们需要回退到稳定的Deployment revision。
### 查看Deployment升级的历史记录
   ```$xslt2
   kubectl rollout history deployment/name
   deployments "nginx-deployment":
   REVISION    CHANGE-CAUSE
   1           kubectl create -f https://kubernetes.io/docs/user-guide/nginx-deployment.yaml--record
   2           kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
   3           kubectl set image deployment/nginx-deployment nginx=nginx:1.91
   # 查看单个revison的详情
   kubectl rollout history deployment/name --revison=2
   ```
因为我们创建Deployment的时候使用了--recored参数可以记录命令，我们可以很方便的查看
每次revision的变化。
### 回退到历史版本
1. 回退当前的rollout到之前的版本
   ```$xslt2
   kubectl rollout undo deployment/name
   ```
2. 也可以使用--revision参数指定某个历史版本
   ```$xslt2
   kubectl rollout undo deployment/name --to-revision=2
   ```
## 扩容Deployment
1. 使用以下命令扩容Deployment
   ```$xslt2
   kubectl scale deployment/name --replicas 10
   ```
2. 也可以使用HPA实现自动伸缩
   ```$xslt2
   kubectl autoscale deployment/name --min=10 --max=15 --cpu-percent=80
   ```   
## 暂停和恢复Deployment
我们可以在发出一次或多次更新请求前暂停一个Deployment，然后在恢复它。这样你就可以
多次暂停和恢复Deployment了。在此期间进行一些修复工作，而不会发出不必要的rollout。
1. 查看Deployment
   ```$xslt2
   kubectl get deployment
   ```
2. 暂停Deployment
   ```$xslt2
   kubectl rollout pause deployment/name
   ```
3. 然后更新Deploymnet
   ```$xslt2
   kubectl set image deployment/name nginx=nginx:1.9.1
   ```
4. 恢复暂停的Deployment
   ```$xslt2
   kubectl rollout resume deployment/name
   ```   
## Deployment状态
Deployment生命周期有很多状态：progressing状态，complete状态，或者fail to progress状态。
1. progressing状态  
 1> Deployment正在创建新的ReplicaSet过程中。  
 2> Deployment正在扩容一个已有的ReplicaSet。    
 3> Deployment正在缩容一个已有的ReplicaSet。  
 4> 有新的可用的pod出现。 
2. complete状态  
 1> Deployment最小可用。最小可用意味着Deployment的可用replica个数等于或者超过Deployment
 策略中的期望个数。  
 2> 所有与该Deployment相关的replica都被更新到了您指定版本，也就说更新完成。  
 3> 该Deployment中没有旧的Pod存在。  
3. fail to progress状态  
 1> 无效的引用    
 2> 不可读的 probe failure  
 3> 镜像拉取错误  
 4> 权限不够  
 5> 范围限制  
 6> 程序运行时配置错误  
## 清理Policy
您可以通过设置.spec.revisonHistoryLimit项来指定deployment最
多保留多少 revision 历史记录。默认的会保留所有的revision；如果将该项设置为0，Deployment就不允许回退了。
