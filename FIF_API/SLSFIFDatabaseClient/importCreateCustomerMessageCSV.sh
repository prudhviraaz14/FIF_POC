#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateCustomerMessageCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importCreateCustomerMessageCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   May 19 2005 16:23:00   banania
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importCreateCustomerMessageCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCreateCustomerMessageCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
