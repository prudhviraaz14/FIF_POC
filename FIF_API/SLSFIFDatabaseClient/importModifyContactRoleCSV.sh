#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateAdjustmentCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importModifyContactRoleCSV.sh-arc  $
# 
#    Rev 1.0   Aug 20 2014 17:11:04   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importModifyContactRoleCSV.sh -Dfif.propertyfile=$PWD/etc/ImportModifyContactRoleCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
