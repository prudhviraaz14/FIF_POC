#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateKBANotificationCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importCreateKBANotificationCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Nov 23 2004 16:04:46   goethalo
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importCreateKBANotificationCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCreateKBANotificationCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
