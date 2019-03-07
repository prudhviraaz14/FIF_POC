#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the Test database client
#
# $Author:   goethalo  $
# $Revision:   1.1  $
# 
# History:
# $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/TestDatabaseClient/runTestDatabaseClient.sh-arc  $
# 
#    Rev 1.1   Mar 02 2004 11:19:44   goethalo
# SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
# 
# ---------------------------------------------------------------------------

# Set the Java JDK Runtime Classes
CPATH=.:$JAVA_HOME/lib/classes.zip

# Add the FIF API package
CPATH=$CPATH:$FIF_HOME/jar/net.arcor.fif.jar

# Add the etc directory
CPATH=$CPATH:$PWD/etc

# Add 3rd party libraries
CPATH=$CPATH:$FIF_HOME/lib/log4j-1.2.7.jar
CPATH=$CPATH:$FIF_HOME/lib/classes12.zip
CPATH=$CPATH:$FIF_HOME/lib/xmlParserAPIs.jar
CPATH=$CPATH:$FIF_HOME/lib/xercesImpl.jar
CPATH=$CPATH:$FIF_HOME/lib/xml-apis.jar
CPATH=$CPATH:$FIF_HOME/lib/xalan.jar
CPATH=$CPATH:$FIF_HOME/lib/oraclexsql.jar
CPATH=$CPATH:$FIF_HOME/lib/xsu12.jar
CPATH=$CPATH:$FIF_HOME/lib/xmlparserv2.jar
CPATH=$CPATH:$FIF_HOME/lib/junit.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mqjms.jar
CPATH=$CPATH:$FIF_HOME/lib/jms.jar
CPATH=$CPATH:$FIF_HOME/lib/standard_blowfish.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-dbcp.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-pool.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-collections.jar

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/TestDatabaseClient.properties -cp $CPATH net.arcor.fif.client.DatabaseClient
