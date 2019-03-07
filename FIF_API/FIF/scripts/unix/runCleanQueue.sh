#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the CleanQueue application
#
# $Author:   lejam  $
# $Revision:   1.3  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/FIF/scripts/unix/runCleanQueue.sh-arc  $
# 
#    Rev 1.3   Aug 09 2007 16:39:34   lejam
# Added connector.jar IT-18536
# 
#    Rev 1.2   Aug 02 2004 15:29:20   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.1   Mar 02 2004 11:18:30   goethalo
# SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
# 
# ---------------------------------------------------------------------------

# Set the Java JDK Runtime Classes
CPATH=.:$JAVA_HOME/lib/classes.zip

# Add the FIF API package
CPATH=$CPATH:$FIF_HOME/jar/net.arcor.fif.jar

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

$JAVA_HOME/bin/java -Dfif.propertyfile=$FIF_HOME/etc/CleanQueue.properties -cp $CPATH net.arcor.fif.apps.CleanQueue $@
