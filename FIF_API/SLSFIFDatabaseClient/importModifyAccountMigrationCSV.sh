#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportModifyAccountMigrationCSV application
#
# $Author:   wlazlow  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importModifyAccountMigrationCSV.sh-arc  $
# 
#    Rev 1.0   Mar 08 2013 12:39:42   wlazlow
# Initial revision.
# 
#
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh
$JAVA_HOME/bin/java -Dfif.appname=importModifyAccountMigrationCSV.sh -Dfif.propertyfile=$PWD/etc/ImportModifyAccountMigrationCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
