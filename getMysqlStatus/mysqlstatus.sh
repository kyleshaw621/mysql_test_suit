#!/bin/sh

#get mysql run status
statusCommand="mysqladmin extended-status"
statusFile="mysqlStatus.tmp"
`$statusCommand > $statusFile`

#get mysql configure status
staticFile="mysqlStatus.static"
mysqld --help --verbose > $staticFile 2>/dev/null

#echo "    ####     key_buffer_size    ####"
##$($statusCommand | grep Key_read)
#cat $statusFile | grep Key_read
#echo " key_reads / key_read_requests should 1:100 ro 1:1000"
#echo ""
#
#echo "    ####     table_cache    ####"
#cat $statusFile  | grep Open | grep tables
#echo ""
#
#
#echo "    ####     query_cache_size    ####"
#cat $statusFile |  grep Qcache
#echo ""
