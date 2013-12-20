#!/usr/bin/expect

# 执行pgbench测试

set timeout 30
spawn pgbench -r -T60 -Upostgres -j8 -c8 pgbenchdb 
#spawn pgbench -r -T30 -Upostgres pgbenchdb
expect "Password:"
send "postgres\r"
interact
