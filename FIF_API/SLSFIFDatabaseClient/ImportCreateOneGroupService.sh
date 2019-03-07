#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   punya  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportCreateOneGroupService.sh-arc  $
# 
#    Rev 1.0   Jun 20 2018 17:03:34   punya
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

$JAVA_HOME/bin/java -Dfif.appname=ImportCreateOneGroupService.sh -Dfif.propertyfile=$PWD/etc/ImportCreateOneGroupCSV.properties -Dfif.clientpropertyfile=$PWD/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
