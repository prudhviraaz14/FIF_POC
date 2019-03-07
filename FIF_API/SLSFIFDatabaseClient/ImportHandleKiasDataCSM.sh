#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportPreselectDeactivationCSM application
#
# $Author:   lalit.kumar-nayak  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportHandleKiasDataCSM.sh-arc  $
# 
#    Rev 1.1   Jul 26 2016 08:51:02   lalit.kumar-nayak
# SPN-FIF-000132535 : File name changed
# 
#    Rev 1.0   May 27 2014 09:51:36   makuier
# Initial revision.
# 
#
# 
# ---------------------------------------------------------------------------
# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=ImportHandleKiasDataCSM.sh -Dfif.propertyfile=$PWD/etc/ImportHandleKiasDataCSM.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSMToDB $@
