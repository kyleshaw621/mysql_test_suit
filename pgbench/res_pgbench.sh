#!/usr/bin/expect
set timeout 30
#-r T30
spawn sudo service postgresql restart
expect "password for kyle:"
send "dingjia\r"
interact
#spawn pgbench -T30 -Ukyle -j4 -c4 pgbenchdb 
#spawn pgbench -T30 -Ukyle pgbenchdb
#expect "Password:"
#send "postgres\r"
#interact
