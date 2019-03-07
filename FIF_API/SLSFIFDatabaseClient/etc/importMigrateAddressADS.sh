#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   naveen.k  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/etc/importMigrateAddressADS.sh-arc  $
# 
#    Rev 1.0   Feb 13 2017 08:58:14   naveen.k
# Initial revision.
# 
# Rev 1.0   Feb 08 2017 naveen
# Initial revision.
# 
# ---------------------------------------------------------------------------
# Set basic FIF env settings
export JAVA_HOME=/opt/java1.5
export FIF_HOME=/pkginf01/home/naveen/DEV117/bin/FIF
# Set basic FIF env settings
. ./runEnvSettings.ksh

$JAVA_HOME/bin/java -Dfif.appname=importMigrateAddressADS.sh -Dfif.propertyfile=$PWD/etc/importMigrateAddressADS.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
