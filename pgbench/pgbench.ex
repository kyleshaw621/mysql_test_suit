#!/usr/bin/expect

# 执行pgbench测试

set timeout 30
spawn pgbench -r -T60 -Ukyle -j4 -c4 pgbenchdb 
#spawn pgbench -r -T30 -Upostgres pgbenchdb
expect "Password:"
send "postgres\r"
interact
