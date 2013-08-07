#!/bin/bash

LogDir=${1:-io_log}
cd $LogDir
allfile=$(ls)

#danwei
logfile=$(echo $allfile | awk '{print $1}')
READ_=$(cat $logfile | grep "Total trans" | awk '{print $2}' | sed -n -e 's#[0-9\.]*\(.*\)#\1#p' )
WRITE_=$(cat $logfile | grep "Total trans" | awk '{print $4}' |  sed -n -e 's#[0-9\.]*\(.*\)#\1#p' )
TOTAL_=$(cat $logfile | grep "Total trans" | awk '{print $(NF-1)}' | sed -n -e 's#[0-9\.]*\(.*\)#\1#p' )
#echo " $READ_ $WRITE_ $TOTAL_"

#echo Title
title="Read($READ_)\tWrite($WRITE_)\tTotal($TOTAL_)\tI/O(s)\tRequest(s)"
echo -e $title
danwei="Gb"

for logfile in $allfile
do
	READ=$(cat $logfile | grep "Total trans" | awk '{print $2'} | sed -n -e "s#\([0-9]*\)$READ_#\1#p")
	WRITE=$(cat $logfile | grep "Total trans" | awk '{print $4'} | sed -n -e "s#\([0-9]*\)$WRITE_#\1#p") 
	TOTAL=$(cat $logfile | grep "Total trans" | awk '{print $(NF-1)'} | sed -n -e "s#\([0-9]*\)$TOTAL_#\1#p" )
	IOS=$(cat $logfile | grep "Total trans" | awk '{print $NF}' | sed -n -e "s#(\(.*\)Mb.*#\1#p" )
	REQUESTS=$(cat $logfile | grep "Requests/sec"| awk '{print $1}')
	
	echo -e "${READ}\t\t${WRITE}\t\t${TOTAL}\t\t${IOS}\t${REQUESTS}"
done
