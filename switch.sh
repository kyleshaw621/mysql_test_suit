#!/bin/bash
Harddisk=harddisk
HarddiskPath_Mysql=/var/lib/mysql
HarddiskPaht_Storage=/opt/backup
Ramdisk=ramdisk
RamdiskPath_Mysql=/mnt/tmpfs/mysql
RamdiskPath_Storage=/mnt/tmpfs/backup

homeDir=$HOME
recycleDir=/tmp/recycDir
mysqlConfig=/etc/mysql/my.cnf
apparmorConfig=/etc/apparmor.d/usr.sbin.mysqld
apacheConfig=/etc/apache2/conf.d/anbaystorage.conf
storageConfig=/opt/scutech/anbay-server/Storage\ Server/storage_server.ini
mysqlTarget=
storageTarget=
mysqlDataDir=
storageDataDir=
logfile=./apache_and_mysql.log
who=`whoami`

Usage() {
	echo "Usage: $0 [ -m mysqldisk ] [ -a storagedisk ] [-s] [-h]"
	echo "	-m mysqldisk	: change mysql to harddisk/ramdisk."
	echo "	-a storagedisk	: change storage files to harddisk/ramdisk."
	echo "	-s 		: display mysql and storage status."
	echo "	-h		: display manual."
	exit 1
}

changeMysql() {
	mysqlStatus
	MysqlOriPath=$mysqlDataDir
	if [ "$mysqlTarget" = "$Harddisk" ];then
		#MysqlOriPath=/mnt/tmpfs/mysql
		MysqlTarPath=$HarddiskPath_Mysql
	elif [ "$mysqlTarget" = "$Ramdisk" ];then
		#MysqlOriPath=/var/lib/mysql
		MysqlTarPath=$RamdiskPath_Mysql
	else
		echo "Mysql : Unknown Target $mysqlTarget"
		return 1
	fi
	if [ "$MysqlOriPath" = "$MysqlTarPath" ];then
		echo "Mysql Data dir has been set to $MysqlTarPath before"
		return 1
	else
		echo "Change Mysql data dir to $MysqlTarPath."
	fi

	#copy file to target
	if [ ! -e "$MysqlTarPath" ];then
		sudo cp -arf $MysqlOriPath $MysqlTarPath
	fi
	sudo sed -i -e "s@^datadir\(.*\)@datadir=$MysqlTarPath@g" $mysqlConfig
	sudo sed -i -e "s@$MysqlOriPath@$MysqlTarPath@g" $apparmorConfig
}

changeStorage() {
	storageStatus
	StorageOriPath=$storageDataDir
	if [ "$storageTarget" = "$Harddisk" ];then
		StorageTarPath=$HarddiskPaht_Storage
	elif [ "$storageTarget" = "$Ramdisk" ];then
		StorageTarPath=$RamdiskPath_Storage
	elif [ "$storageTarget" = "home" ];then
		StorageTarPath=$homeDir/backupData
	else
		echo "Storage : Unknown Target $storageTarget"
		return 1
	fi
	if [ "$StorageOriPath" = "$StorageTarPath" ];then
		echo "Storage Data dir has been set to $StorageTarPath before"
		return 1
	else
		echo "Change Storage dir to $StorageTarPath."
	fi
	sudo sed -i -e "s@$StorageOriPath@$StorageTarPath@g" $mysqlConfig
	sudo sed -i -e "s@$StorageOriPath@$StorageTarPath@g" $apacheConfig
	sudo sed -i -e "s@$StorageOriPath@$StorageTarPath@g" "$storageConfig"
	. /etc/apache2/envvars
	mkdir -p $StorageTarPath
	mkdir -p $recycleDir
	sudo rm -rf $recycleDir/*
	sudo mv $StorageTarPath/* $recycleDir/
	sudo chown -R $who:$who $recycleDir
	sudo chown $APACHE_RUN_USER:$APACHE_RUN_GROUP $StorageTarPath
}

apacheControl() {
	sudo service apache2 restart > $logfile
}


mysqlControl() {
	control=$1
	sudo service mysql $control > $logfile
	if [ $control = "start" -a $? -ne 0 ];then
		echo "Mysql Start failed"
		exit 1
	fi
}

mysqlStatus() {
	if [ ! -e "$mysqlConfig" ];then
		echo "Can not find $mysqlConfig"
		exit 1
	fi
	mysqlDataDir=$(cat $mysqlConfig | grep ^datadir | awk -F'=' '{print $NF}')
}

storageStatus() {
	if [ ! -e "$apacheConfig" ];then
		echo "Can not find $apacheConfig"
		exit 1
	fi
	storageDataDir=$(cat $apacheConfig | grep AnbayStorageActivityDir | head -1 | awk '{print $NF}')
}

AllStatus() {
	mysqlStatus
	storageStatus
	echo "mysqlDataDir = $mysqlDataDir"
	echo "storageDataDir = $storageDataDir"
	exit 0
}



if [ $# -eq 0 ];then
	Usage
fi
while getopts m:a:sh OPTION ; do
	case "$OPTION" in
		m) mysqlTarget="$OPTARG" ;;
		a) storageTarget="$OPTARG" ;;
		s) AllStatus ;;
		h) Usage;;
	esac
done

echo "" > $logfile
mysqlControl stop
if [ ! -z $mysqlTarget ];then
	changeMysql
fi

if [ ! -z $storageTarget ];then
	changeStorage
fi
mysqlControl start
apacheControl
