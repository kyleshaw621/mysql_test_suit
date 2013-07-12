#!/bin/bash
#test all in ramdisk and harddisk
#switchmysql.sh 
#switchstorage.sh

workingpath=`pwd`
backupScriptPath=/home/kyle/anbay-improvement/anbay_improvement/post_backup_insert_catalog
changeAll=$workingpath/switch.sh
repeatTest=$workingpath/repeatTest.sh
ram=ramdisk
disk=harddisk
testtime=6
#test all in harddisk
if [ "$1" = "mysql" ];then
	stroageSelect="$disk"
else
	stroageSelect="$disk $ram"
fi

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
	for storageIn in $stroageSelect
	do
		storageTarget=$storageIn
		echo_title $mysqlTarget $storageTarget
		$changeAll -m $mysqlTarget -a $storageTarget
		if [ $? -ne 0 ];then
			echo "Some is wrong in $changeAll"
			exit 1
		fi
		#cd $backupScriptPath
		$repeatTest $testtime
		#cd $workingpath
	done
		
done

echo "****************************************"
echo "* restore mysql and storage to $disk *"
echo "****************************************"
$changeAll -m $disk -a $disk
