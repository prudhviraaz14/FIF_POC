#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ISIS-FIF database client
#
# $Author:   goethalo  $
# $Revision:   1.1  $
# 
# History:
# $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/ISISFIFDatabaseClient/runISISFIFDatabaseClient.sh-arc  $
# 
#    Rev 1.1   Aug 02 2004 15:29:32   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.0   May 28 2004 12:16:46   goethalo
# Initial revision.
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
CPATH=$CPATH:$FIF_HOME/lib/ojdbc14.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-dbcp-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-pool-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-collections-3.0.jar
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

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/ISISFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.client.DatabaseClient
