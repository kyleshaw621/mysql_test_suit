#!/bin/bash
#计算缓存命中率,命中率越大越好

readsRequest=$(mysqladmin extended-status  | grep Innodb_buffer_pool_read_requests | awk '{print $(NF-1)}')
reads=$(mysqladmin extended-status  | grep Innodb_buffer_pool_reads | awk '{print $(NF-1)}')

sub=$(echo "$readsRequest - $reads" | bc)
percent=$(echo "$sub / $readsRequest" | bc -l )
#percent=$(echo "1.5 * 1.5" | bc -l )
echo "Innodb_buffer_pool_read_requests = $readsRequest"
echo "Innodb_buffer_pool_reads = $reads"
echo "sub = $sub"
echo "percent = $percent"
