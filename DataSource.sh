#!/bin/bash
#date

DATE=`date +%Y-%m-%d`

for i in `seq 1 10`; do
        cp /usr/tomcat.$i/conf/server.xml /usr/tomcat.$i/conf/server.xml.$DATE ;
        echo "Backup complete for /usr/tomcat.$i/conf/server.xml"
        echo "updating /usr/tomcat.$i/conf/server.xml"
        sed -i '/javax.sql.DataSource/a\              testWhileIdle="true"\n              testOnBorrow="true"\n              testOnReturn="false"\n              validationInterval="30000"\n              timeBetweenEvictionRunsMillis="30000"\n              logAbandoned="true"\n              minEvictableIdleTimeMillis="30000"\n              maxWaitMillis="5000"' /usr/tomcat.$i/conf/server.xml
        echo "updated server.xml on tomcat.$i"
        echo "restarting tomcat.$i"
        service tomcat.$i restart
done


echo "**********"
echo "update completed"
