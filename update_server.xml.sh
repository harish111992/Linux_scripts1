#!/bin/bash
Date=`date +%Y-%m-%d`
for i in `seq 1 10`;
do
/bin/cp -rp /usr/tomcat.$i/conf/server.xml /usr/tomcat.$i/bin/server.xml_org
echo "Backup complete for /usr/tomcat.$i/conf/server.xml"
echo "updating /usr/tomcat.$i/conf/server.xml"
## /tmp/content is the file, having data which need to be append on server.xml after the pattern <GlobalNamingResources>
sed -i '/<GlobalNamingResources>/r /tmp/content' /usr/tomcat.$i/conf/server.xml
echo "updated server.xml file on tomcat.$i"
done
####-----------TESTED---------####
