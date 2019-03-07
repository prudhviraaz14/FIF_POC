#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   punya  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importHandleChangeNumOfVoiceChannels.sh-arc  $
# 
#    Rev 1.0   Jun 08 2018 14:02:08   punya
# Initial revision.
# 
# ---------------------------------------------------------------------------
# Set basic FIF env settings
#export JAVA_HOME=$JAVA_HOME
#export FIF_HOME=$FIF_HOME

export JAVA_HOME=/opt/java1.5
export FIF_HOME=/pkginf01/WORK/piselali/build121/bin/FIF
# Set basic FIF env settings
. ./runEnvSettings.ksh

$JAVA_HOME/bin/java -Dfif.appname=importHandleChangeNumOfVoiceChannels.sh -Dfif.propertyfile=$PWD/etc/ImportHandleChangeNumOfVoiceChannelsCSV.properties -Dfif.clientpropertyfile=$PWD/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
