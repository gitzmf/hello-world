# ˽�вֿ�Harbor�ʼ�
## Harbor���
1. ��ʲô��  
�ٷ����Harbor��һ������Դ��������ӳ�������ͨ�����ڽ�ɫ�ķ��ʿ�������������ɨ��
�����е�©����������ǩ��Ϊ�����Ρ� ��ΪCNCF������Ŀ��Harbor�ṩ�Ϲ��ԣ����ܺͻ������ԣ�
�԰�������Kubernetes��Docker����ԭ������ƽ̨��������ȫ�ع�����  
����˵��Harbor����һ����Դ�ľ������ֿ⣬����Githubһ�������������Ǵ��һЩ�����ļ���
��ϸ���ݣ��ο��ٷ��ĵ� 
2. ΪʲôҪ�ã�  
֮ǰ��Springboot��Ŀÿ�ζ���Ҫ�ڷ������������񣬵����ж�̨��������Ҫ�õ���������һ���
�ظ���ÿ̨�������ϴ���һ�Σ�����û��һ���м�洢��������ǹ�����Щ���������еķ���������
������������ļ��أ�Harbor�����þ��ǰ����ǹ����񣬲��÷ֲ�ʽ�ܹ��������ǿ��������������
��ȥ���ǹ����õľ����ļ���Ȼ���ֻ����������ǲ����Ѿ���docker hub���� docker hub��ЩԶ��
�ֿ�����ȷʵ�����ǵ�������Ҫ�һЩ˽�о���ֿ⣬����ѹ�˾��Ŀ���⹫����ʱ��Harbor��
�������ˣ�����ܶ๫˾Ҳ�����Լ���˾�˽�е�nexus������������˾�ڲ���Ӧ��package��
## Harbor���

| ���               | ����                                      |
| ------------------ | ----------------------------------------- |
| harbor-adminserver | ���ù�������                              |
| harbor-db          | Mysql���ݿ�                               |
| harbor-jobservice  | ��������                              |
| harbor-log         | ��¼������־                              |
| harbor-ui          | Web����ҳ���API                          |
| nginx              | ǰ�˴�������ǰ��ҳ��;����ϴ�/����ת�� |
| redis              | �Ự                                      |
| registry           | ����洢                                  |

<img src="./images/1563523214247767.png" style="zoom: 80%;" />

## Harbor�
1. ��githubѡ��һ��harbor release�汾����
    ```$xslt2
    https://github.com/goharbor/harbor/releases #���ڷ������ع���
    ����ֱ��
    wget https://storage.googleapis.com/harbor-releases/release-1.10.0/harbor-offline-installer-v1.10.2.tgz # ��������˵�ȽϿ�
    ```
    
2. �ϴ���linux��������Ȼ���ѹ
    ```$xslt2
    tar -zxvf harbor-v1.0.1.tar.gz
    ```
    
3. �޸�harbor�����ļ�habor.yml
    ```$xslt2
    #��������
    hostname: 192.168.199.132
    
    #����http����
    # http related config
    http:
      # port for http, default is 80. If https enabled, this port will redirect to https port
      port: 8090
      
    #���ù���Ա����
    harbor_admin_password: admin123
    
    #����https
    #https:
      # https port for harbor, default is 443
     # port: 443
    ```
ע�⣺  
�����޸���hostnameΪ���������ip���˿ڰ�Ĭ��80�˿��滻��8090�������޸��˹���Ա����Ϊadmin123��
��Ҫע�⣬������������https����������Ҫ����https����Ҫ����֤���key��ָ��λ�á�
    
4. ����Docker http����Ȩ�� 
    DockerĬ���ǲ�֧��http����ע����������ʹ��dockerȥ����harbor���񡣷��򣬻ᱨ������

  �޸�/etc/docker/daemon.json���ã�����һ�����ã�

  ```
  {
    "insecure-registries": ["192.168.199.132:8090"]
  }
  ```

   ����docker����

  ```
  systemctl daemon-reload
  systemctl start docker
  ```

5. ����HarborӦ��

   ����û��Docker������harbor�ᱨ��

   ```
   root@zmf harbor]# sh install.sh 
   [Step 0]: checking if docker is installed ...
   Note: docker version: 19.03.7
   [Step 1]: checking docker-compose is installed ...
   Note: docker-compose version: 1.25.0
   [Step 2]: loading Harbor images ...
   Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
   ```

   ��Ҫ�Ȱ�װ`Docker`��`docker-compose`�����������Docker��ִ��`install.sh`���Զ���ɰ�װ
    ```
[root@zmf harbor]# sh install.sh 
   ...
   Creating network "harbor_harbor" with the default driver
   Creating harbor-log ... done
   Creating harbor-portal ... done
   Creating registry      ... done
   Creating redis         ... done
   Creating harbor-db     ... done
   Creating registryctl   ... done
   Creating harbor-core   ... done
   Creating nginx             ... done
   Creating harbor-jobservice ... done
   ? ----Harbor has been installed and started successfully.----
    ```

	���ʱ���Ѿ���ʾ��װ�ɹ���

6. ����Harbor

   ����������������������õ�ip�Ͷ˿�`192.168.101.11:8090`���ͻῴ��`harbor`��½ҳ��.

   - �˺� - admin
   - ���� - admin123
## Harbor����

1. ����һ��Harbor��Ŀ�����÷��ʼ��𡢴洢������

   

   

2. ʹ��Docker��¼Harbor

   ```
   [root@zmf harbor]# docker login 192.168.199.132:8090
   Username: admin
   Password: 
   WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
   Configure a credential helper to remove this warning. See
   https://docs.docker.com/engine/reference/commandline/login/#credentials-store
   
   Login Succeeded
   ```

   

3. ��Image���

   ```
   docker tag hello-world:latest  hello-world:1.0
   ```

   

4. ��������Harbor

   ʹ��Harbor��ip��ַ��ǰ�洴���õ���Ŀ���ƽ��з���

   ```
   [root@zmf harbor]# docker push 192.168.199.132:8090/hello-world/hello-world:1.0
   The push refers to repository [192.168.101.11:8090/hello-world/hello-world:1.0]
   21f243c9904f: Pushed 
   edd61588d126: Pushed 
   9b9b7f3d56a0: Pushed 
   f1b5933fe4b5: Pushed 
   latest: digest: sha256:86a6289143d0a8a4cc94880b79af36416d07688585f8bb1b09fd4d50cd166f46 size: 1159
   ```

   

5. ��Harbor��ȡ����

   ```
   [root@zmf harbor]# docker pull 192.168.199.132:8090/hello-world/hello-world:1.0
   latest: Pulling from credit-facility/credit-facility-image
   Digest: sha256:86a6289143d0a8a4cc94880b79af36416d07688585f8bb1b09fd4d50cd166f46
   Status: Downloaded newer image for 192.168.101.11:8090/credit-facility/credit-facility-image:latest
   192.168.101.11:8090/credit-facility/credit-facility-image:lates
   ```

   

## Harbor UIʹ���ֲ�

![Harborʹ���ֲ�](./images/Harbor%E4%BD%BF%E7%94%A8%E6%89%8B%E5%86%8C.png)