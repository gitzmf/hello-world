# Docker Compose
## Docker Compose简介
   docker-compose是一个容器中的服务编排工具。
   docker镜像在创建之后，往往需要自己手动pull来获取镜像，然后执行
docker run命令来运行。当服务需要用到多种容器，容器之间又产生了各种
依赖和连接的时候，部署一个服务的手动操作是令人感到十分厌烦的。
   dcoker-compose技术，就是通过一个.yml配置文件，将所有的容器的
部署方法、文件映射、容器连接等等一系列的配置写在一个配置文件里，最后
只需要执行docker-compose up命令就会像执行脚本一样的去一个个安装容
器并自动部署他们，极大的便利了复杂服务的部署。
## Docker Compose工作原理
   Docker Compose 将所管理的容器分为三层，分别是工程（project）、
   服务（service）、容器（container）。
   服务(service) ：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例。
   工程(project) ：由一组关联的应用容器组成一个完整业务单元，在docker-compose.yml
   文件中定义。
   docker-compose运行的目录下的所有文件（docker-compose.yml, extends文件或环境变量文件等）
组成一个工程，若无特殊指定工程名即为当前目录名。一个工程当中可包含多个服务，每个服务中定义了容器运
行的镜像，参数，依赖。一个服务当中可包括多个容器实例，docker-compose并没有解决负载均衡的问题，因
此需要借助其他工具实现服务发现及负载均衡。借助其他工具做到服务发现以及负载均衡可以将docker-compose
间接的理解为ansible，我们可以使用ansible来为多台主机部署服务，而docker-compose可以为多个容器部署
服务Docker Compose的工程配置文件默认为docker-compose.yml
   docker-compose项目整个结构是由python完成的，调用docker服务来提供API对容器进行管理，因此操作的
平台支持docker API，就可以通过docker-compose进行服务的编排。
## Docker Compose安装
1. 下载命令脚本
    ```xslt2
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    ```
2. 给脚本可执行权限
    ```$xslt2
    chmod +x /usr/local/bin/docker-compose
    ```    
3. 做命令软链
    ```$xslt2
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    ```
4. 查看Docker Compose是否安装成功
    ```$xslt2
    docker-compose version
    ```    