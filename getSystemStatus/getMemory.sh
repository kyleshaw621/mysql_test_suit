#!/bin/bash

psname=repeatTest.sh
sleeptime=10
outputfile=./memorystatus
title=$(free -m | sed -n '1p')

if [ -z $1 ];then
	echo "Use default setting. delay 3 seconds."
else
	sleeptime=$1
fi


echo $title > $outputfile
echo $title
while true
do
	tempout=$(free -m | sed -n '2p')
	memfree=$(echo $tempout | awk '{print $4}')
	membuffers=$(echo $tempout | awk '{print $6}')
	memcached=$(echo $tempout | awk '{print $7}')
	truefreemem=`echo "$memfree + $membuffers + $memcached" | bc `
	output="$tempout =$truefreemem="
	echo $output
	echo $output >> $outputfile
	ps -ef | grep -v grep | grep $psname  > /dev/null 2>&1
	if [ $? -eq 1 ];then
		echo "end"
		exit 1
	fi
	sleep $sleeptime
done
