#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   lalit.kumar-nayak  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportOnbMigration.sh-arc  $
# 
#    Rev 1.0   Feb 15 2018 14:00:02   lalit.kumar-nayak
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
export JAVA_HOME=/opt/java1.5
export FIF_HOME=/pkginf01/WORK/sibanipa/Build120/bin/FIF
# Set basic FIF env settings
. ./runEnvSettings.ksh

$JAVA_HOME/bin/java -Dfif.appname=importEnterprise2Standard.sh -Dfif.propertyfile=$PWD/etc/ImportOnbMigrationMigrationCSV.properties -Dfif.clientpropertyfile=$PWD/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
