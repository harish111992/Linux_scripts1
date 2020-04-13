#!/bin/bash
Date=`date +%Y-%m-%d`
HOST=`/bin/hostname`_tc
APPD_PATH=/usr/appdynagent/ver4.5.13.27526/logs
for i in `seq 1 10`;
do
/bin/mkdir $APPD_PATH/$HOST$i
/bin/chown -R tomcat$i:tomcat $APPD_PATH/$HOST$i
echo "created $HOST$i "
ls -ld "$APPD_PATH/$HOST$i"
done
######--------TESTED---------#####
