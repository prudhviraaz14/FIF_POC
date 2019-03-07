#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the WOE-FIF queue client
#
# $Author:   schwarje  $
# $Revision:   1.3  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/WOEFIFQueueClient/runWOEFIFQueueClient.sh-arc  $
# 
#    Rev 1.3   Jun 18 2010 17:20:22   schwarje
# changes for CPCOM Phase 2: new FIF client type accepting SOM orders
# 
#    Rev 1.2   Jun 01 2010 18:28:30   schwarje
# IT-26029: updates
# 
#    Rev 1.1   Jul 30 2007 15:34:52   schwarje
# IT-19536: added new library to classpath
# 
#    Rev 1.0   Mar 31 2005 13:49:42   goethalo
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

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/WOEFIFQueueClient.properties -cp $CPATH net.arcor.fif.client.SynchronousFIFQueueClient
