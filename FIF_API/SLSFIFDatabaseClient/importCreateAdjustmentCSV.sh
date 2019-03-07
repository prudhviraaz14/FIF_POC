#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateAdjustmentCSV application
#
# $Author:   lejam  $
# $Revision:   1.2  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importCreateAdjustmentCSV.sh-arc  $
# 
#    Rev 1.2   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.1   Aug 02 2004 15:29:56   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.0   Apr 28 2004 14:07:10   goethalo
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importCreateAdjustmentCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCreateAdjustmentCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
