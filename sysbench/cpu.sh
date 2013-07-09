#!/bin/bash
#usage : ./cpu.sh [threadsNum]
logfile=cpu.log
threads=2
PrimeNum=20000

Usage() {
	cat <<EOF
	Usage : $0 [ -p number ] [ -t threads ] [-a] [-h]
		-p : to designate prime number.
		-t : to designate thread number.
		-a : analyze last time output.
		-h : display help message.
EOF
exit 1
}

analyse() {
	PrimeNum=$(cat $logfile | grep "Maximum prime" | awk '{print $NF}')
	totaltime=$(cat $logfile | grep "total time:" | awk '{print $NF}')
	echo "计算 $PrimeNum 以内的最大的素数使用了 $totaltime"
}

while getopts t:p:ha OPTION; do
	case "$OPTION" in
		t) threads="$OPTARG" ;;
		p) PrimeNum="$OPTARG" ;;
		a) analyse
		   exit 0;;
		h) Usage ;;
	esac
done
echo "thread is ${threads}, prime number is ${PrimeNum}."

sysbench --test=cpu --cpu-max-prime=$PrimeNum --num-threads=$threads run > $logfile
if [ $? -eq 0 ];then
	analyse
else
	echo "Some errors. Please read log file $logfile"
fi
