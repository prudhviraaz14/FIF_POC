#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateMOSCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importGenericFifRequest.sh-arc  $
# 
#    Rev 1.0   Apr 20 2012 08:07:30   schwarje
# Initial revision.
# 
#    Rev 1.0   Feb 03 2011 14:36:48   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importGenericFifRequest.sh -Dfif.propertyfile=$PWD/etc/ImportGenericFifRequest.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
