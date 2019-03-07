#!/bin/sh
#
# Shell script for starting all ISIS migration related processes
#
# @author goethalo
# @date 2004-03-15
#

echo "--> Starting all ISIS migration processes...\n"

# Start CBM and PSM

echo "Starting CBM and PSM..."
cd /ccb/ccb20b/ccb20bis/env/IS/CCB-70.00/bin
IS_CbmFacAppSer32is 1&
IS_CbmFacAppSer32is 2&
IS_CbmFacAppSer32is 3&
IS_PsmProIntAppSer32is 1&
IS_PsmProIntAppSer32is 2&
IS_PsmProIntAppSer32is 3&
IS_PsmProIntAppSer32is 4&
IS_PsmProIntAppSer32is 5&


# Start the CCM MQ Reader

echo "Starting MQ Reader..."
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/com.ibm.mq.jar:.
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/com.ibm.mqbind.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/com.ibm.mqjms.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/jms.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/jndi.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/jta.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/ldap.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/providerutil.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/connector.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/rmm.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/fscontext.jar
export CLASSPATH=$CLASSPATH:/opt/mqm/java/lib/postcard.jar
nohup java CcmMQReader -v  -prop $PROFILE/CcmMQReader_isis.properties >/dev/null 2>/dev/null &


# Start FIF-API

echo "Starting FIF-API..."
cd /home/ccb20bis/WORK/FIF/ISISMigrationDatabaseClient
export FIF_HOME=/home/ccb20bis/WORK/FIF/FIF
CPATH=.:$JAVA_HOME/lib/classes.zip
CPATH=$CPATH:$FIF_HOME/jar/net.arcor.fif.jar
CPATH=$CPATH:$PWD/etc
CPATH=$CPATH:$FIF_HOME/lib/log4j-1.2.7.jar
CPATH=$CPATH:$FIF_HOME/lib/classes12.zip
CPATH=$CPATH:$FIF_HOME/lib/xmlParserAPIs.jar
CPATH=$CPATH:$FIF_HOME/lib/xercesImpl.jar
CPATH=$CPATH:$FIF_HOME/lib/xml-apis.jar
CPATH=$CPATH:$FIF_HOME/lib/xalan.jar
CPATH=$CPATH:$FIF_HOME/lib/junit.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mqjms.jar
CPATH=$CPATH:$FIF_HOME/lib/jms.jar
CPATH=$CPATH:$FIF_HOME/lib/standard_blowfish.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-dbcp.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-pool.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-collections.jar

nohup $JAVA_HOME/bin/java -Xmx1024m -Dfif.propertyfile=ISISMigrationDatabaseClient -cp $CPATH net.arcor.fif.client.DatabaseClient  >/dev/null 2>&1 &

echo "\n--> Started all ISIS migration processes...\n"



