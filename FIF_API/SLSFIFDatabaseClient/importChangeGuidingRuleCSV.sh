#!/usr/bin/sh
# ---------------------------------------------------------------------------
# UNIX shell script for launching the ImportChangeGuidingRuleCSV application
#
# $Author:   lejam  $
# $Revision:   1.3  $
#
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importChangeGuidingRuleCSV.sh-arc  $
# 
#    Rev 1.3   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.2   Aug 02 2004 15:29:54   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.1   Jul 26 2004 09:45:40   goethalo
# SPN-FIF-000024162: Fixed header.
# 
#    Rev 1.0   Jul 12 2004 15:15:34   IARIZOVA
# Initial revision.
#  
# ---------------------------------------------------------------------------


# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importChangeGuidingRuleCSV.sh -Dfif.propertyfile=$PWD/etc/ImportChangeGuidingRuleCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
