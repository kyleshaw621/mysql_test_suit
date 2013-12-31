#!/bin/bash

. ./pg_config.sh

test_time=60
# 执行pgbench测试
pgbench -r -T60 -Ukyle -j4 -c4 -p${port} pgbenchdb 
