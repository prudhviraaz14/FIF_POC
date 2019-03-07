#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the MigrationAddServiceSubscriptionCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importAddServiceSubscriptionCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Dec 15 2006 14:31:26   wlazlow
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importAddServiceSubscriptionCSV.sh -Dfif.propertyfile=$PWD/etc/ImportAddServiceSubscriptionCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
 
