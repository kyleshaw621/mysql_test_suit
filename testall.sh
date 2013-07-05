#!/bin/bash
#test all in ramdisk and harddisk
#switchmysql.sh 
#switchstorage.sh

workingpath=`pwd`
backupScriptPath=/home/kyle/anbay-improvement/anbay_improvement/post_backup_insert_catalog
changeMysql=$workingpath/switchmysql.sh
changeStorage=$workingpath/switchstorage.sh
ram=ramdisk
disk=harddisk
testtime=6
#test all in harddisk
echo_title() {
	mysql=$1
	storage=$2
	echo "**************************************"
	echo "******	 mysql=$mysql		******"
	echo "******	 storage=$storage	******"
	echo "**************************************"
}


for mysqlIn in $disk $ram
do
	mysqlTarget=$mysqlIn
	for storageIn in $disk $ram
	do
		storageTarget=$storageIn
		echo_title $mysqlTarget $storageTarget
		$changeMysql $mysqlTarget > /dev/null 
		$changeStorage $storageTarget > /dev/null
		cd $backupScriptPath
		$backupScriptPath/repeatTest.sh $testtime
		cd $workingpath
	done
		
done
#echo_title($disk,$disk)
#$changeMysql $disk
#$changeStorage $disk
#$backupScript


