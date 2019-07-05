#!/bin/sh
#从库使用主库的备份账号连接主库，并开始备份
masterip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql-master)
passwd=$(sed '/SLAVE_PASSWD/!d;s/.*=//' ../.env)
replname=$(sed '/REPL_NAME/!d;s/.*=//' ../.env)
replpasswd=$(sed '/REPL_PASSWD/!d;s/.*=//' ../.env)
docker exec -it mysql-slave mysql -uroot -p${passwd} \
-e "CHANGE MASTER TO MASTER_HOST='${masterip}', MASTER_PORT=3306, MASTER_USER='${replname}', MASTER_PASSWORD='${replpasswd}', MASTER_AUTO_POSITION=1, MASTER_SSL=1;" \
-e "START SLAVE;" 
