#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportChangeCustomerCSV application
#
# $Author:   lejam  $
# $Revision:   1.2  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importChangeCustomerCSV.sh-arc  $
# 
#    Rev 1.2   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.1   Aug 02 2004 15:29:54   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.0   May 18 2004 13:11:08   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh
$JAVA_HOME/bin/java -Dfif.appname=importChangeCustomerCSV.sh -Dfif.propertyfile=$PWD/etc/ImportChangeCustomerCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
