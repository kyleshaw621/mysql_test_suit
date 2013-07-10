#!/bin/bash

repeat=1
inputRepeat=$1
workingDir=`pwd`
#workingDir=`dirname $0`
homeDir=`echo $HOME`
improveScirptDir=$homeDir/anbay-improvement/anbay_improvement/post_backup_insert_catalog
SwitchAll=$workingDir/switch.sh
apacheLog=/var/log/apache2/error.log
outputstring=/tmp/outputstring
recycleDir=/tmp/recycleDir
DataDir=
insert_use_time=
backup_file_amount=
get_block_use_time=
who=`whoami`

test_tools_exist() {
	#get mysql status tools
	if [ -e "$SwitchAll" ];then
		$SwitchAll -s
		DataDir=$($SwitchAll -s | grep storageDataDir | awk '{print $NF}')
		if [ "x$DataDir" = "x" -o "x$DataDir" = "x="  ];then
			echo "DataDir is empty"
			exit 1
		else
			echo "DataDir is #$DataDir#"
		fi
	else
		echo "Can not find $SwitchAll"
		exit 1
	fi

	#improvement scritps
	if [ ! -e "$improveScirptDir" ];then
		echo "Can not found improvement scritps in $improveScirptDir."
		exit 1
	fi
}

get_insert_catalog_time() {
	hours=
	minutes=
	seconds=
	#begin time
        insert_begin_line=$(cat $apacheLog | grep "begin insert catalog of dir" | tail -1 | awk '{print $4}') #eg 09:56:18
	hours=$(echo $insert_begin_line | awk -F'[:]' '{print $1}')
	minutes=$(echo $insert_begin_line | awk -F'[:]' '{print $2}')
	seconds=$(echo $insert_begin_line | awk -F'[:]' '{print $3}')
	insert_begin_time=$(echo "$hours * 3600 + $minutes * 60 + $seconds" | bc )

	#end time
        insert_end_line=$(cat $apacheLog | grep "end insert catalog" | tail -1 | awk '{print $4}')
	hours=$(echo $insert_end_line | awk -F'[:]' '{print $1}')
	minutes=$(echo $insert_end_line | awk -F'[:]' '{print $2}')
	seconds=$(echo $insert_end_line | awk -F'[:]' '{print $3}')
	insert_end_time=$(echo "$hours * 3600 + $minutes * 60 + $seconds " | bc )
	insert_use_time=$(echo "$insert_end_time - $insert_begin_time " | bc )
	#echo $insert_use_time
}

get_block_time() {
	hours=
	minutes=
	seconds=
	#begin time
        get_block_begin_line=$(cat $apacheLog | grep "start get_block" | tail -1 | awk '{print $4}') #eg 09:56:18
	hours=$(echo $get_block_begin_line | awk -F'[:]' '{print $1}')
	minutes=$(echo $get_block_begin_line | awk -F'[:]' '{print $2}')
	seconds=$(echo $get_block_begin_line | awk -F'[:]' '{print $3}')
	get_block_begin_time=$(echo "$hours * 3600 + $minutes * 60 + $seconds" | bc )

	#end time
        get_block_end_line=$(cat $apacheLog | grep "return from get_block" | tail -1 | awk '{print $4}')
	hours=$(echo $get_block_end_line | awk -F'[:]' '{print $1}')
	minutes=$(echo $get_block_end_line | awk -F'[:]' '{print $2}')
	seconds=$(echo $get_block_end_line | awk -F'[:]' '{print $3}')
	get_block_end_time=$(echo "$hours * 3600 + $minutes * 60 + $seconds " | bc )
	get_block_use_time=$(echo "$get_block_end_time - $get_block_begin_time " | bc )
	#echo "get_block_use_time = $get_block_use_time"
}

get_backup_file_amount() {
	backup_file_amount=$(cat $apacheLog | grep "read_file_chunk_ex" | tail -1 | awk '{print $NF}')
	#echo "$backup_file_amount"
}

test_mysql() {
	if [ ! -z $inputRepeat ];then
		repeat=$inputRepeat
	fi
	echo "Repeat $repeat"
	echo "" > $outputstring
	
	for((i=0;i<$repeat;i++))
	do
		#sudo rm -rf $DataDir/*
		mkdir -p $recycleDir
		rm -rf $recycleDir/*
		sudo mv $DataDir/* $recycleDir/
		sudo chown -R $who:$who $recycleDir
		$improveScirptDir/reset_db.sh
		teststring=$(python $improveScirptDir/agent_simulate_wrapper.py )
		echo "$teststring" >> $outputstring
		lengthOfTime="$(echo $teststring | tail -1 | awk '{print $(NF-1)}') "
		get_backup_file_amount
		get_insert_catalog_time
		get_block_time
		echo "$i : files = $backup_file_amount, all time = ${lengthOfTime}, insert catalog = $insert_use_time get_block = $get_block_use_time"
		#restart mysql to avoid cache
		sudo service mysql restart > /dev/null
	done
}

cd $improveScirptDir
test_tools_exist
test_mysql
#echo "files = $backup_file_amount ,  all time = ${lengthOfTime}, insert catalog = $insert_use_time seconds"
