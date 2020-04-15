# 指定基础镜像，在其上进行定制，注意是小写
FROM java:8
# 这里的 /tmp目录就会在运行时自动挂载为匿名卷，任何向/tmp中写入的信息都不会记录进容器存储层
VOLUME /user/local/zmf/tmp
# 复制上下文目录下的target/hello-world-0.0.1-SNAPSHOT.jar 到容器里
COPY target/hello-world-0.0.1-SNAPSHOT.jar hello-world.jar
# bash方式执行，使hello-world.jar可访问
# RUN新建立一层，在其上执行这些命令，执行结束后， commit 这一层的修改，构成新的镜像。
RUN bash -c "touch /hello-world.jar"
# 声明运行时容器提供服务端口，这只是一个声明，在运行时并不会因为这个声明应用就会开启这个端口的服务
EXPOSE 9000
# 指定容器启动程序及参数   <ENTRYPOINT> "<CMD>"，注意是双引号
ENTRYPOINT ["java","-jar","hello-world.jar"]
