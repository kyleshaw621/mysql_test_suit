#!/bin/bash
#用于分析二进制日志(binlog)设置是否够大
#设置binlog_cache_size可以提高binlog的纪录效率
cacheUse=$(mysqladmin extended-status  | grep  Binlog_cache_use | awk '{print $(NF-1)}')
cachaInserts=$(mysqladmin extended-status  | grep Binlog_cache_disk_use | awk '{print $(NF-1)}')

echo "Binlog_cache_use = $cacheUse"
echo "Binlog_cache_disk_use = $cachaInserts"
