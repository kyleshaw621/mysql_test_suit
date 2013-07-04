#!/bin/sh

if [ $# -ne "1" ];then
	echo "$0 [prepare | run | clean | auto ]"
	exit 1
fi

_prepare() {
	sysbench --test=fileio --file-total-size=500M prepare
}

_run() {
	sysbench --test=fileio --file-total-size=500M --file-test-mode=rndwr --init-rng=on --max-time=30 --max-requests=0 run 
}

_clean() {
	sysbench --test=fileio --file-total-size=500M cleanup 
}

options=$1
case $options in
	prepare)
		echo "prepare"
		_prepare;;
	run)
		echo "run"
		_run;;
	clean)
		echo "clean"
		_clean;;
	auto)
		echo "auto"
		_prepare
		_run
		_clean;;
	*)
		echo "unknown options"
		exit;;
esac
	
