#!/bin/bash
# -
#Tomcat uninstallation scriptlet
# 
# -
PROGRAM=`basename $0`

echo -n "$PROGRAM: uninstalling tomcat from server "; sleep 2;
for NUM in `seq 1 10`
do
	RV_PS=`ps --no-heading -u tomcat${NUM}`; RC_PS=$?;
	[ $RC_PS -eq 0 ] && /etc/rc.d/init.d/tomcat.${NUM} stop
done
for NUM in `seq 1 10`
do
	/sbin/chkconfig --del tomcat.${NUM}
	rm -rf /usr/tomcat.${NUM}
	userdel -r tomcat${NUM}
	echo -n ". ";
done
cp /etc/java/java.conf.original /etc/java/java.conf
echo -n ". ";
rm /etc/logrotate.d/tomcat*
echo -n ". ";
rm /etc/rc.d/init.d/tomcat.*
echo -n ". ";
rm /usr/tomcat
echo -n ". ";
rm -rf /usr/apache-tomcat-7.0.50
echo -n ". ";
userdel -r tomcat
# echo -n ". "; groupdel tomcat ; # removed by 'userdel -r tomcat'
echo ". done";

