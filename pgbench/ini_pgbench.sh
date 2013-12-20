#!/bin/sh

# 初始化pgbench需要用到的数据

scaling_factor=20
db_name=pgbenchdb
# -i :表示调用初始化模式
pgbench -i -s  pgbenchdb

