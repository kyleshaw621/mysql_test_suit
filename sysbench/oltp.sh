#!/bin/bash

#--oltp-read-only=on 
threads=2
user=root
password=dingjia
repeat=5
maxtime=60
tableSize=1000000

run_test() {
	for((i=1;i<=$repeat;i++));do 
		echo "*		time $i	size=$tableSize	*"
		echo "*********************************" >> $logfile
		echo "*		time $i	size=$tableSize	*" >> $logfile
		echo "*********************************" >> $logfile
		sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=$tableSize --mysql-user=$user --mysql-password=$password --max-time=$maxtime --max-requests=0 --num-threads=2 run >> $logfile
	done
}
 
prepare() {
	mysql -u$user -p$password -e "use sbtest; drop table sbtest;"
	sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=$tableSize --mysql-user=$user --mysql-password=$password --mysql-socket=/var/run/mysqld/mysqld.sock prepare 
}

Usage() {
	cat <<EOF
Usage: $0 [-p] [-r] [-a] [-c] [-h] [-u username] [-p password] [-t repeatTime] [-s tableSize]
	p : prepare databases
	r : run test
	a : auto run prepare and test
	c : clean log file
	u : mysql user name
	p : mysql password
	t : run test times
	s : table size (default is 1000000)
	h : display help message
EOF
	exit 0
}

cleanlog() {
	rm  oltp-*.log
	exit 0
}

if [ $# -eq 0 ];then
	Usage
fi
while getopts ahpru:k:t:s: OPTION; do
	case $OPTION in
		u) user=$OPTARG ;;
		k) password=$OPTARG ;;
		t) repeat=$OPTARG ;;
		s) tableSize=$OPTARG ;;
		c) cleanlog;;
		p) status=prepare ;;
		r) status=runtest ;;
		a) status=auto ;;
		h) Usage ;;
		*) Usage ;;
	esac
done
logfile=oltp-$tableSize.log
echo "" > $logfile
echo "Table Size=$tableSize"
if [ $status = "prepare" ];then
	prepare
elif [ $status = "runtest" ];then
	run_test
elif [ $status = "auto" ];then
	prepare
	run_test
else
	echo "unknown options"
fi
