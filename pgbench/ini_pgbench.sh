#!/bin/sh


. ./pg_config.sh
# 初始化pgbench需要用到的数据

scaling_factor=100

# -i :表示调用初始化模式
#echo "pgbench -p${port} -i -U $db_name -s $scaling_factor  pgbenchdb"
pgbench -p${port} -i -U $db_name -s $scaling_factor  pgbenchdb
