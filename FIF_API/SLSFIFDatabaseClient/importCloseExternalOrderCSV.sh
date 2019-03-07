#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateAdjustmentCSV application
#
# $Author:   lejam  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importCloseExternalOrderCSV.sh-arc  $
# 
#    Rev 1.0   Nov 24 2011 14:57:16   lejam
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importCloseExternalOrderCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCloseExternalOrderCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
