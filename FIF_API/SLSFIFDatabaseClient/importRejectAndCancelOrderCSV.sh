#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateAdjustmentCSV application
#
# $Author:   lejam  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importRejectAndCancelOrderCSV.sh-arc  $
# 
#    Rev 1.0   Apr 14 2011 16:26:00   lejam
# Initial Revision
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importRejectAndCancelOrderCSV.sh -Dfif.propertyfile=$PWD/etc/ImportRejectAndCancelOrderCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
