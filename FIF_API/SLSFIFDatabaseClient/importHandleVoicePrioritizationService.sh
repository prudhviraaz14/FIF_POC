#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   lejam  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importHandleVoicePrioritizationService.sh-arc  $
# 
#    Rev 1.0   Jun 05 2018 16:52:18   lejam
# Initial revision.
# 
# ---------------------------------------------------------------------------
# Set basic FIF env settings
#export JAVA_HOME=$JAVA_HOME
#export FIF_HOME=$FIF_HOME

export JAVA_HOME=/opt/java1.5
export FIF_HOME=/pkginf01/WORK/punyan/B121/bin/FIF

# Set basic FIF env settings
. ./runEnvSettings.ksh

$JAVA_HOME/bin/java -Dfif.appname=importTerminateVoicePrioritizationService.sh -Dfif.propertyfile=$PWD/etc/ImportHandleVoicePrioritizationServiceCSV.properties -Dfif.clientpropertyfile=$PWD/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
