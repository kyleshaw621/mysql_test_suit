#!/bin/bash
user=root
password=dingjia

which mysqltuner > /dev/null 2>&1 
if [ $? -ne 0 ];then
	echo "please install mysqltuner."
	echo "sudo apt-get install mysqltuner"
	exit 1
fi

mysqltuner --user $user --pass $password
