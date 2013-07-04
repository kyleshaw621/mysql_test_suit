#!/bin/bash
MYSQLCONFIG=/etc/mysql/my.cnf
APPARMOR=/etc/apparmor.d/usr.sbin.mysqld
ORIPATH=/var/lib/mysql
TARPATH=/mnt/tmpfs/mysql

if [ $# -ne 1 ];then
	echo "$0 [ harddisk | ramdisk | status ]"
	exit 1
elif [ $1 = "harddisk" -o $1 = "ramdisk" -o $1 = "status" ];then
	option=$1
else
	echo "unknown option"
	echo "$0 [ harddisk | ramdisk | status ]"
	exit 1
fi

change2harddist() {
	sudo sed -i -e "s@^datadir\(.*\)@datadir=$ORIPATH@g" $MYSQLCONFIG
	sudo sed -i -e "s@$TARPATH@$ORIPATH@g" $APPARMOR
	sudo /etc/init.d/apparmor reload
}

change2ramdisk() {
	if [ ! -e "/mnt/tmpfs/mysql" ];then
		sudo cp -arf /var/lib/mysql /mnt/tmpfs/mysql
	fi
	sudo sed -i -e "s@^datadir\(.*\)@datadir=$TARPATH@g" $MYSQLCONFIG
	sudo sed -i -e "s@$ORIPATH@$TARPATH@g" $APPARMOR
	sudo /etc/init.d/apparmor reload
}

mysql_control() {
	control=$1
	sudo service mysql $control
	if [ $control = "start" -a $? -ne 0 ];then	
		exit 1
	fi
}

if [ $option = "status" ];then
	cat $MYSQLCONFIG | grep ^datadir
	exit 0
fi

echo "switch mysql to $option"
mysql_control stop
if [ $option = "harddisk" ];then
	change2harddist
elif [ $option = "ramdisk" ];then
	change2ramdisk
fi
mysql_control start
sudo service apache2 restart
