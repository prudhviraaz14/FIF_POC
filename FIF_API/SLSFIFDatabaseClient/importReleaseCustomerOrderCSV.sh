#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateCustomerMessageCSV application
#
# $Author:   wlazlow  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importReleaseCustomerOrderCSV.sh-arc  $
# 
#    Rev 1.0   Nov 17 2011 13:09:56   wlazlow
# Initial revision.
# 
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importReleaseCustomerOrderCSV.sh -Dfif.propertyfile=$PWD/etc/ImportReleaseCustomerOrderCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
