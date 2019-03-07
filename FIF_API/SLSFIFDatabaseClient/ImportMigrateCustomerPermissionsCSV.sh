#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateCustomerPermissionsCSV 
# application
#
# $Author:   sibani.panda  $
# $Revision:   1.1  $
# 
#    Rev 1.0   Mar 30 2014 13:28:14   sibanipa
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importMigrateCustomerPermissionsCSV.sh -Dfif.propertyfile=$PWD/etc/ImportMigrateCustomerPermissionsCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
