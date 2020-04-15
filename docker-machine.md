# Docker Machine 
## ��飺  
   docker-machine�ǽ��docker���л������⡣Docker Machine��һ�ֿ�������������
�����ϰ�װ Docker �Ĺ��ߣ�������ʹ�� docker-machine ����������������
Docker Machine Ҳ���Լ��й������е�docker������  
���䣺  
    Docker Compose��Ҫ��������������⣬���漰��������Ӧ��ʱ��ʹ��docker������������
    ���ʱ�����ͨ����дdocker-compose-*.yml �����ļ�ʵ�ֶ������Ĵ����Լ��������ͨ�����⡣
    Docker Swarm�ǽ������������������Ȳ�������⣬��������������������ϵ�Docker�����Ĺ��ߣ�
    ���Ը�����������������������״̬��Ŀǰ������ʹ��Kubernets��k8s�����й���Docker
    Swarm�Ѿ���������������������˼�������Ƿǳ��õģ����������������Ļ�ʯ��
## Docker Machine������װ
1. �Ѱ�װDocker����
2. ����Docker Machine�������ļ��������ѹ��������PATH�С�
    ```$xlst2
      base=https://github.com/docker/machine/releases/download/v0.16.0 &&
      curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
      sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
      chmod +x /usr/local/bin/docker-machine
    ```
3. ͨ����ʾ������汾��鰲װ�Ƿ�ɹ�
    ```$xslt2
       docker-machine --version
    ```    
4. ��װ���ȫ�ű�
    ```$xslt2
    # ������ȫ�ű����ؽű�
    nano bash_complate.sh
    # ���ƹ�������Ҫ��ӵĽű�����
    base=https://raw.githubusercontent.com/docker/machine/v0.16.0
    for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
    do
      sudo wget "$base/contrib/completion/bash/${i}" -P /etc/bash_completion.d
    done
    # ִ�нű�
    source bash_complate.sh
    # ��ʾwget������ڣ����а�װ
    yum install wget
    #  Ҫ����docker-machine��ǳ�����ʾ��$(__docker_machine_ps1)��PS1������� ����~/.bashrc��          
    PS1='[\u@\h \W$(__docker_machine_ps1)]\$ ' 
    ```   
    
���⣺  
    1. raw.githubusercontent.com���Ӿܾ�
        ԭ����Ϊgithub�ǹ�����վԭ�򣬻���docker�ĵ�Ҳ�ǣ���ǽ�ˣ����Է���ʧ��
## Docker Machine������
1. �г����û���
   ```xslt2
   docker-machine ls
   ```
2. ��������
   demo: ������Ϊtest��
   ```$xslt2
   docker-machine create --driver virtualbox test
   docker-machine create --driver generic --generic-ip-address 192.168.199.140 host2
   # ����˵��
   -d/--driver  #ָ������ʲô���⻯����������
   --generic-ip-address  #ָ��Ҫ��װ��������IP�������Ǳ��ص�IP��Ҳ����˵����Ҳ���Ը��������װDocker��ǰ����SSH root�û��⽻����¼��˽Կ��֤��
   ```
���䣺
   1. ǰ����Ҫ����SSH root�û��⽻����¼��˽Կ��֤
   ```$xslt2
   ssh-keygen
   ssh-copy-id -i root@192.168.199.134
   ```
   2. �����г�����������
   ��At least 192MB more space needed on the / filesystem.��
   ```$xslt2
   linux �ռ䲻���ˣ���ô�죿
   1> �鿴�ռ����:df -h
   2> �鿴�����ں�: uname -r
   3> �����ں� rpm -qa | grep kernel
   4> ɾ��������ں�
   su -c 'yum remove kernel-devel-2.6.32-431.20.3.el6.i686'
   5> ɾ��ϵͳ��־ rm -rf /var/log/*
   6> ɾ�� rm -rf /usr/local/src ע��������ܴ����㰲װ���ļ�
   ```
   �鿴������չ���
   ```xslt2
   fdisl -l
   # fdisk -l������ڣ�ԭ������fdisk���������������·����
   whereis fdisk �鿴fidsk����·��
   # �鿴��������·��
   echo $PATH
   # ��fdisk��ӵ���ǰ��������·���м���
   ln -s /usr/sbin/fdisk /usr/local/bin/
   ```
3. ��������
   ```$xslt2
   docker-machine start test 
   ```   
4. �������
   ```$xslt2
   docker-machine ssh test
   ```
5. �鿴��ǰ״̬����Ļ���
   ```$xslt2
   docker-machine active
   ```   
6. ����Զ��docker����
   ```$xsl2
   docker-machine env test
   # ��ǰִ��bash����Ϊ�����host1����exit֮���ֱ�ӶϿ�xshell������
   bash
   # ����test������
   eval $(docker-machine env test)
   ```  
7. ��������
   ```$xslt2
    staging
    config���鿴��ǰ����״̬ Docker ������������Ϣ��
    creat������ Docker ����
    env����ʾ���ӵ�ĳ��������Ҫ�Ļ�������
    inspect��	�� json ��ʽ���ָ��Docker����ϸ��Ϣ
    ip��	��ȡָ�� Docker �����ĵ�ַ
    kill��	ֱ��ɱ��ָ���� Docker ����
    ls��	�г����еĹ�������
    provision��	��������ָ������
    regenerate-certs��	Ϊĳ�������������� TLS ��Ϣ
    restart��	����ָ��������
    rm��	ɾ��ĳ̨ Docker ��������Ӧ�������Ҳ�ᱻɾ��
    ssh��	ͨ�� SSH ���ӵ������ϣ�ִ������
    scp��	�� Docker ����֮���Լ� Docker �����ͱ�������֮��ͨ�� scp Զ�̸�������
    mount��	ʹ�� SSHFS �Ӽ����װ�ػ�ж��Ŀ¼
    start��	����һ��ָ���� Docker ��������������Ǹ�����������������������
    status��	��ȡָ�� Docker ������״̬(������Running��Paused��Saved��Stopped��Stopping��Starting��Error)��
    stop��	ֹͣһ��ָ���� Docker ����
    upgrade��	��һ��ָ�������� Docker �汾����Ϊ����
    url��	��ȡָ�� Docker �����ļ��� URL
    version��	��ʾ Docker Machine �İ汾�������� Docker �汾
    help��	��ʾ������Ϣ
   ```   
## Docker machineж��
1. ɾ�����еļ����
   ```$xslt2
   docker-machine rm -f $(docker-machine ls -q)
   ```   
2. ж��docker machine
   ```$xslt2
   rm $(which docker-machine)
   ```        
        