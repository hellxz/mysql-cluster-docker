#!/bin/bash
# 此脚本用于重启主从集群后，从节点无法同步主节点数据的问题
passwd=$(sed '/SLAVE_PASSWD/!d;s/.*=//' ../.env)
docker exec -it mysql-slave mysql -uroot -p${passwd} -e "RESET SLAVE;"

