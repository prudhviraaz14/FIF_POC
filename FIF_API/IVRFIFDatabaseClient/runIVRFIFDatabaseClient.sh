#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the IVR-FIF database client
#
# $Author:   schwarje  $
# $Revision:   1.2  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/IVRFIFDatabaseClient/runIVRFIFDatabaseClient.sh-arc  $
# 
#    Rev 1.2   Jun 01 2010 18:27:22   schwarje
# IT-26029: updates
# 
#    Rev 1.1   Jul 30 2007 15:30:18   schwarje
# IT-19536: added new library to classpath
# 
#    Rev 1.0   Apr 23 2007 14:36:38   schwarje
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
CPATH=$CPATH:$FIF_HOME/lib/connector.jar

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/IVRFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.client.SynchronousDatabaseClient
