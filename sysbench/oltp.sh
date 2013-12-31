#!/bin/bash
#!/bin/bash -aux

###common
#--oltp-read-only=on 
THREADS=2		#total number of worker threads
MAXREQUIRE=0		#0 mean unlimit
MAXTIME=60
TABLESIZE=10000000
repeat=5
#DBType=pgsql		#or mysql
DBType=mysql
DBName=sbtest

#mysql
mysql_user=root
mysql_password=dingjia
mysql_param="--db-driver=mysql --mysql-table-engine=innodb --mysql-user=$mysql_user --mysql-password=$mysql_password"

#pgsql
pgsql_user=kyle
pgsql_password=dingjia
pgsql_host=localhost
pgsql_port=5433 #discriminate different version of pg
pgsql_param="--db-driver=pgsql --pgsql-host=$pgsql_host --pgsql-user=$pgsql_user --pgsql-password=$pgsql_password --pgsql-port=$pgsql_port"

if [ -e ./sysbench ];then
	ldd ./sysbench > /dev/null 2>&1
	if [ $? -eq 0 ];then
		bin_sysbench=./sysbench
	else
		bin_sysbench=sysbench
	fi
else
	bin_sysbench=sysbench
fi

run_test() {
	for((i=1;i<=$repeat;i++));do 
		logfile=$DBType/$DBType-oltp-$TABLESIZE-p$THREADS.log.$i
		echo "" > $logfile
		echo "*	$DBType	time=$i	size=$TABLESIZE	pthread=$THREADS*"
		echo "*********************************************"		>> $logfile
		echo "*	$DBType	time=$i	size=$TABLESIZE	pthread=$THREADS*"	>> $logfile
		echo "*********************************************"		>> $logfile
		#$bin_sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=$TABLESIZE --mysql-user=$user --mysql-password=$password --max-time=$MAXTIME --max-requests=$MAXREQUIRE --num-threads=$THREADS run >> $logfile
		echo "$bin_sysbench --test=oltp $param --oltp-table-size=$TABLESIZE --max-time=$MAXTIME --max-requests=$MAXREQUIRE --num-threads=$THREADS run " >> $logfile
		#if [ "$DBType" = "pgsql" ];then
		#	echo "clean database $DBName"
		#	vacuumdb --full --dbname=$DBName
		#fi
		$bin_sysbench --test=oltp $param --oltp-table-size=$TABLESIZE --max-time=$MAXTIME --max-requests=$MAXREQUIRE --num-threads=$THREADS run >> $logfile
	done
}
 
prepare() {
	if [ "$DBType" = "pgsql" ];then
		echo "Input pgsql user($pgsql_user) password:"
		psql -U$pgsql_user -d$DBName -W <<EOF
		drop table $DBName;
EOF
	### 使用sysbench插入数据的速度非常慢，所以当创建表成功好，可以杀掉sysbench的进程，然后用下面的两条语句插入数据到PostgreSQL中
	#1) truncate sbtest ;
	#2) INSERT INTO sbtest(k, c, pad) select 0,' ','qqqqqqqqqqwwwwwwwwwweeeeeeeeeerrrrrrrrrrtttttttttt' from generate_series(1,10000000);
	else
		mysql -u$mysql_user -p$mysql_password -e "use sbtest; drop table sbtest;"
		prepare_param="--mysql-socket=/var/run/mysqld/mysqld.sock"
	#	$bin_sysbench --test=oltp --mysql-table-engine=innodb --oltp-table-size=$TABLESIZE --mysql-user=$user --mysql-password=$password --mysql-socket=/var/run/mysqld/mysqld.sock prepare 
	fi
	start_time=`date +%s`
	$bin_sysbench --test=oltp --oltp-table-size=$TABLESIZE $param $prepare_param prepare
	end_time=`date +%s`
	use_time=`expr $end_time - $start_time`
	echo "Prepare using time = $use_time seconds"
}

Usage() {
	cat <<EOF
Usage: $0 [-p] [-r] [-a] [-c] [-h] [-u username] [-p password] [-t repeatTime] [-s tableSize] [-d dbtype] [-x thread]
	d : database type [mysql|pgsql] (default:$DBType)
	p : prepare databases
	r : run test
	a : auto run prepare and test
	c : clean log file
	u : mysql user name
	p : mysql password
	t : run test times
	s : table size (default is $TABLESIZE)
	h : display help message
EOF
	exit 0
}

cleanlog() {
	rm  *-oltp-*.log
	exit 0
}

if [ $# -eq 0 ];then
	Usage
fi
while getopts ahprt:s:d:x: OPTION; do
	case $OPTION in
		d) DBType=$OPTARG ;;
		t) repeat=$OPTARG ;;
		s) TABLESIZE=$OPTARG ;;
		x) THREADS=$OPTARG ;;
		c) cleanlog;;
		p) status=prepare ;;
		r) status=runtest ;;
		a) status=auto ;;
		h) Usage ;;
		*) Usage ;;
	esac
done
if [ $DBType = "mysql" ];then
	param=$mysql_param
elif [ $DBType = "pgsql" ];then
	param=$pgsql_param
else
	echo "Unkown DBtype:$DBType."
	exit 1
fi
mkdir -p $DBType
if [ "x$status" = "xprepare" ];then
	prepare
elif [ "x$status" = "xruntest" ];then
	run_test
elif [ "x$status" = "xauto" ];then
	prepare
	run_test
else
	echo "unknown action"
fi
