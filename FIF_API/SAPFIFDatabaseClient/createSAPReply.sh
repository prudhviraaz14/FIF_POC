#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ExportDBStatusToCSV application
#
# $Author:   goethalo  $
# $Revision:   1.2  $
# 
# History:
# $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/SAPFIFDatabaseClient/createSAPReply.sh-arc  $
# 
#    Rev 1.2   Aug 02 2004 15:29:46   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.1   Mar 02 2004 11:19:26   goethalo
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
CPATH=$CPATH:$FIF_HOME/lib/ojdbc14.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-dbcp-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-pool-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-collections-3.0.jar
CPATH=$CPATH:$FIF_HOME/lib/standard_blowfish.jar

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/ExportDBStatusToCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SAPFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ExportDBStatusToCSV $@
