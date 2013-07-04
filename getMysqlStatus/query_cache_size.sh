#!/bin/bash
#计算query cachae的命中率
cacheHits=$(mysqladmin extended-status  | grep Qcache_hits | awk '{print $(NF-1)}')
cachaInserts=$(mysqladmin extended-status  | grep Qcache_inserts | awk '{print $(NF-1)}')

add=$(echo "$cacheHits + $cachaInserts" | bc)
percent=$(echo "$cacheHits / $add" | bc -l)

echo "Qcache_hits = $cacheHits"
echo "Qcache_inserts = $cachaInserts"
echo "hit percent = $percent"
