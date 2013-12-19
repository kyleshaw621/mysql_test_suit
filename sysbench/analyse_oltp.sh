#!/bin/bash

log_filedir=$1
if [ "x$log_filedir" = "x" ];then
	echo "Usage :$0 logdir"
	exit 1
fi

#echo Title
title="threads\ttime\t\ttotal_events\tevents(/s)\t95%event_time(/ms)\tThread_fair"
echo -e $title

cd $log_filedir
#allfile=$(ls -f | grep oltp)
allfile=$(ls | grep oltp)

for logfile in $allfile
do
	#get threads
	threads=$(cat $logfile | grep "Number of threads" | awk -F: '{print $2'})
	
	#get time
	times=$(cat $logfile | grep "total time:" | awk -F: '{print $2'})
	
	#get total_events
	total_events=$(cat $logfile | grep "transactions" | awk -F: '{print $2'} | awk '{print $1}')
	#get events(/s)
	pre_events=$(cat $logfile | grep "transactions" | awk -F: '{print $2'} | awk '{print $2}' | sed -n -e 's#(\(.*\)#\1#p')
	
	#total_r_and_w=$(cat $logfile | grep "read/write requests:" | awk -F: '{print $2'} | awk '{print $1}')
	#pre_r_and_w=$(cat $logfile | grep "read/write requests:" | awk -F: '{print $2'} | awk '{print $2}' | sed -n -e 's#(\(.*\)#\1#p')
	
	#get 95%event_time(/ms)
	event_95=$(cat $logfile | grep "95 percentile" | awk -F: '{print $2}' | sed -n -e "s#\([1-9]*\)ms#\1#p" )
	
	#get Thread_fair
	threads_fair=$(cat $logfile | grep "events (avg/stddev)" | awk -F: '{print $2}' | awk -F/  '{print $1}')
	
	#remove writespace and tab in strings
	threads=$(echo -e $threads | tr -d " \t")
	times=$(echo -e $times | tr -d " \t")
	total_events=$(echo -e $total_events | tr -d " \t")
	pre_events=$(echo -e $pre_events | tr -d " \t")
	pre_r_and_w=$(echo -e $pre_r_and_w | tr -d " \t")
	event_95=$(echo -e $event_95 | tr -d " \t")
	threads_fair=$(echo -e $threads_fair | tr -d " \t")
	
	#output result
	echo -e "${threads}\t${times}\t${total_events}\t\t${pre_events}\t\t${pre_r_and_w}   \t${event_95}\t\t\t${threads_fair}"

done
