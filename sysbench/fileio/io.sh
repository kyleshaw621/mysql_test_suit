#!/bin/sh
logfile=io.log
filesize=500M
testmode=rndrw

Usage() {
	cat <<EOF
	Usage : $0 [-p] [-r] [-c] [-a] [-k] [-h]
		p : prepare files
		r : run test
		c : clean files
		a : auto run prepare, tset and clean
		k : analyse last output
		h : display help message.
		m : test mode. can select seqwr[顺序写], seqrewr[顺序重写], seqrd[顺序读], rndrd[顺序重读], rndwr[随机写], rndrw[随机读写](default). 
EOF
}

_prepare() {
	echo "prepare files size is $filesize"
	sysbench --test=fileio --file-total-size=$filesize prepare
}

_run() {
	echo "test type is $testmode. filesize is $filesize"
	sysbench --test=fileio --file-total-size=$filesize --file-test-mode=$testmode --init-rng=on --max-time=30 --max-requests=0 run > $logfile
}

_clean() {
	sysbench --test=fileio --file-total-size=$filesize cleanup 
}

analyse() {
	Throughput=$(cat $logfile | grep "Total trans" | awk '{print $NF}')
	request=$(cat $logfile | grep "Requests/sec"| awk '{print $1}')
	echo "吞吐量: $Throughput"
	echo "请求量: $request Requests/sec"
}

while getopts prcahk OPTION; do
	case "$OPTION" in 
		p) _prepare ;;
		r) _run ;;
		c) _clean ;;
		a) _prepare
		   _run
		   _clean ;;
		h) Usage;;
		k) analyse
		   exit 0;;
		*) Usage;;
	esac
done
