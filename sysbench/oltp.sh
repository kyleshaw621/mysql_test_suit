#!/bin/sh
#--oltp-read-only=on 
#--oltp-table-size=1000000
sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=10000000 --mysql-user=root --mysql-password=dingjia --max-time=60 --max-requests=0 --num-threads=2 run
#sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=1000000 --mysql-user=root --mysql-password=dingjia --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=2 run
