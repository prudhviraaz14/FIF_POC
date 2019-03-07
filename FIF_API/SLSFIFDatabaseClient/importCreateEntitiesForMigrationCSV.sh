#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateEntitiesForMigrationCSV application
#
# $Author:   goethalo  $
# $Revision:   1.4  $
# 
# History:
# $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/SLSFIFDatabaseClient/importCreateEntitiesForMigrationCSV.sh-arc  $
# 
#    Rev 1.4   Aug 02 2004 15:29:56   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.3   Apr 28 2004 14:09:56   goethalo
# IT-k-000012599: Add fif.appname system property.
# 
#    Rev 1.2   Mar 25 2004 16:55:22   schwarje
# reset for FIF-API 05
# 
#    Rev 1.0   Mar 18 2004 14:54:08   schwarje
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
CPATH=$CPATH:$FIF_HOME/lib/jms.jar
CPATH=$CPATH:$FIF_HOME/lib/standard_blowfish.jar

$JAVA_HOME/bin/java -Dfif.appname=importCreateEntitiesForMigrationCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCreateEntitiesForMigrationCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
