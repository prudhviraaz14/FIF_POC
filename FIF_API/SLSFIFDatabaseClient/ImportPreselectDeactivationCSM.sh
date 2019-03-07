#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportPreselectDeactivationCSM application
#
# $Author:   makuier  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportPreselectDeactivationCSM.sh-arc  $
# 
#    Rev 1.0   May 27 2014 09:51:36   makuier
# Initial revision.
# 
#
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh
$JAVA_HOME/bin/java -Dfif.appname=ImportPreselectDeactivationCSM.sh -Dfif.propertyfile=$PWD/etc/ImportPreselectDeactivationCSM.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSMToDB $@
