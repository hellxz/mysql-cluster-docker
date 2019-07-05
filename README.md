## 写在前边

搭建MySQL读写分离主从集群，这里未使用`binlog`方式，使用的是`GTID`方式
对应我的博客<https://www.cnblogs.com/hellxz/p/docker-mysql-cluster.html>

## 主从目录结构

```bash
.
├── bin
│   ├── add-slave-account-to-master.sh
│   ├── reset-slave.sh
│   ├── slave-replias-master-start.sh
│   └── stop-replicas.sh
├── config
│   ├── master.cnf
│   └── slave.cnf
├── docker-compose.yml
├── .env
├── master-data
├── show-slave-status.sh
└── slave-data
```

## 目录/文件说明：

- `bin/add-slave-account-to-master.sh` ：Master节点添加备份账户的脚本
- `config/master.cnf` : MySQL Master节点的配置文件
- `config/slave.cnf` : MySQL Slave节点的配置文件
- `docker-compose.yml` :  构建主从节点与挂载数据目录的docker-compose配置文件
- `master-data` : 主节点数据位置，当然生产环境要挂到别的位置
- `slave-data` ：从节点数据位置，当然生产环境要挂到别的位置
- `bin/slave-replias-master-start.sh` ：从节点添加主节点备份账号信息并开启备份的脚本
- `bin/stop-replicas.sh` ：关闭从节点备份的脚本
- `bin/reset-slave.sh` : 重置从节点备份状态，修复由于主从集群重启后无法建立集群的问题
- `.env` : 环境变量文件
- ` bin/show-slave-status.sh `: 查看主从连接状态的脚本

## 搭建过程：

1.修改`.env`文件

```bash
# default environment arguments for docker-compose.yml
# set master data dir
MASTER_DATA=./master-data
# set slave data dir
SLAVE_DATA=./slave-data
# set master & slave root password
MASTER_PASSWD=P@ssw0rd
# set slave root passwor
SLAVE_PASSWD=P@ssw0rd
# set replicas mysql account name
REPL_NAME=replicas
# set replicas mysql password
REPL_PASSWD=replicasPasswd
```

> - `MASTER_DATA`是Master节点的数据目录，需要修改到宿主机对应的位置，SLAVE_DATA亦然。
>
> - `MASTER_PASSWD`是主节点的root密码，bin目录下的脚本会读取这个变量的值从而进行访问数据库
> - `SLAVE_PASSWD`是从节点的root密码，脚本也会读
> - `REPL_NAME`是主节点要创建的账户名，从节点通过这个账户进行访问
> - `REPL_PASSWD`是主节点要创建的`REPL_NAME`对应的密码

2.启动两个节点，执行`docker-compose up -d`

检查已经启动

![](https://img2018.cnblogs.com/blog/1149398/201907/1149398-20190705165416268-583688376.png)

3.进入bin目录，执行脚本

```bash
cd bin
./add-slave-account-to-master.sh #读取mysql密码，为主节点添加备份账户
./slave-replias-master-start.sh #从节点使用备份账户连接主节点，开启备份
```

4.查看集群状态，在bin目录下执行`./show-slave-status.sh`

![](https://img2018.cnblogs.com/blog/1149398/201907/1149398-20190705181450047-1683700564.png)

到此搭建完成。

## 故障修复

1.重启MySQL集群后从节点无法正常恢复解决。

执行bin目录下的`reset-slave.sh`, 之后 连接数据库尝试，问题已经解决。

> 另提供了一个关闭备份的脚本`stop-slave.sh`