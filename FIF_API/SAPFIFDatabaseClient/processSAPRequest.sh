#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCSVToDB application
#
# $Author:   goethalo  $
# $Revision:   1.4  $
# 
# History:
# $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/SAPFIFDatabaseClient/processSAPRequest.sh-arc  $
# 
#    Rev 1.4   Aug 02 2004 15:29:48   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.3   Apr 28 2004 14:18:56   goethalo
# IT-k-000012599: Corrected fif.appname system property.
# 
#    Rev 1.2   Apr 28 2004 14:05:26   goethalo
# IT-k-000012599: Added fif.appname system property.
# 
#    Rev 1.1   Mar 02 2004 11:19:30   goethalo
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

$JAVA_HOME/bin/java processSAPRequest.sh -Dfif.propertyfile=$PWD/etc/ImportCSVToDB.properties -Dfif.clientpropertyfile=$PWD/etc/SAPFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
