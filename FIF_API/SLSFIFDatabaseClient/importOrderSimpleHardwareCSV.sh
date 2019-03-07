#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportOrderSimpleHardwareCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importOrderSimpleHardwareCSV.sh-arc  $
# 
#    Rev 1.0   Dec 21 2015 11:14:26   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettings.sh

$JAVA_HOME/bin/java -Dfif.appname=importOrderSimpleHardwareCSV.sh -Dfif.propertyfile=$PWD/etc/ImportOrderSimpleHardwareCSV.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
