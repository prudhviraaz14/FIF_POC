#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the MigrationAddServiceSubscriptionCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importAddCcmParameterMapCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Jun 12 2008 17:23:26   lejam
# Initial Revision
# 
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importAddCcmParameterMapCSV.sh -Dfif.propertyfile=$PWD/etc/ImportAddCcmParameterMapCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
 
