#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   lalit.kumar-nayak  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportMarketingPermission.sh-arc  $
# 
#    Rev 1.0   Feb 06 2018 10:22:32   lalit.kumar-nayak
# Initial revision.
# 
#    Rev 1.0   Feb 13 2017 08:58:14   naveen.k
# Initial revision.
# 
# Rev 1.0   Feb 08 2017 naveen
# Initial revision.
# 
# ---------------------------------------------------------------------------
# Set basic FIF env settings
# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=ImportMarketingPermission.sh -Dfif.propertyfile=$PWD/etc/ImportMarketingPermissionCSV.properties -Dfif.clientpropertyfile=$PWD/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
