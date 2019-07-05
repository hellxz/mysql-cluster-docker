#!/bin/sh
#为主节点添加备份用户
passwd=$(sed '/MASTER_PASSWD/!d;s/.*=//' ../.env);
replname=$(sed '/REPL_NAME/!d;s/.*=//' ../.env);
replpasswd=$(sed '/REPL_PASSWD/!d;s/.*=//' ../.env);

docker exec -it  mysql-master mysql -uroot -p${passwd} \
-e "CREATE USER '${replname}'@'%' IDENTIFIED BY '${replpasswd}' REQUIRE SSL;" \
-e "GRANT REPLICATION SLAVE ON *.* TO 'replicas'@'%';"
