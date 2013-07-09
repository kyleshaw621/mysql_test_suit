#!/bin/bash
#WARNING:you should add $TARPATH to /etc/apparmor.d/usr.sbin.mysqld in ubuntu.

HOMEDIR=$HOME
RecycleDir=/tmp/storageRecycle
MYSQLCONF=/etc/mysql/my.cnf
APACHECONF=/etc/apache2/conf.d/anbaystorage.conf
STORAGECONF=/opt/scutech/anbay-server/Storage\ Server/storage_server.ini
#ORIPATH=/opt/backup
#TARPATH=/mnt/tmpfs/backup

usage() {
	echo "$0 [ harddisk | ramdisk | status | home ]"
	exit 1
}

if [ $# -ne 1 ];then
	usage
elif [ $1 = "harddisk" -o $1 = "ramdisk" -o $1 = "status" -o $1 = "home" ];then
        option=$1
else
        echo "unknown option"
	usage
fi

changestorage() {
	sudo sed -i -e "s@$ORIPATH@$TARPATH@g" $MYSQLCONF
	sudo sed -i -e "s@$ORIPATH@$TARPATH@g" $APACHECONF
	sudo sed -i -e "s@$ORIPATH@$TARPATH@g" "$STORAGECONF"
	. /etc/apache2/envvars
	mkdir -p $TARPATH
	sudo chown $APACHE_RUN_USER:$APACHE_RUN_GROUP $TARPATH
	echo "remove dir $TARPATH data"
	mkdir $RecycleDir
	sudo mv ${TARPATH}/* $RecycleDir/
	#sudo rm -rf ${TARPATH}/*
}

ORIPATH=$(cat $APACHECONF | grep AnbayStorageActivityDir | head -1 | awk '{print $NF}')
if [ $option = "harddisk" ];then
	TARPATH=/opt/backup
elif [ $option = "ramdisk" ];then
	TARPATH=/mnt/tmpfs/backup
elif [ $option = "home" ];then
	TARPATH=$HOMEDIR/backupData
else
	cat $APACHECONF | grep AnbayStorageActivityDir
	exit 0
fi
echo "switch storage to $option"
changestorage
sudo service apache2 restart
sudo service mysql restart
