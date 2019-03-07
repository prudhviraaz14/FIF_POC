#!/usr/bin/sh
# ---------------------------------------------------------------------------
# NT script for launching the MoveCustomerWithinHierarchy application
#
# $Author:   lejam  $
# $Revision:   1.5  $
#
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importMoveCustomerWithinHierarchyCSV.sh-arc  $
# 
#    Rev 1.5   Nov 25 2010 11:24:08   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.4   Sep 16 2004 13:51:14   IARIZOVA
# changed properties file name
# 
#    Rev 1.3   Sep 16 2004 12:33:36   IARIZOVA
# changed properties file name
# 
#    Rev 1.2   Sep 15 2004 13:38:32   IARIZOVA
# wrong comment symbols corrected
# 
#    Rev 1.1   Aug 02 2004 15:29:58   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.0   Jul 21 2004 17:22:48   IARIZOVA
# Initial revision.
# 
# ---------------------------------------------------------------------------


# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importMoveCustomerWithinHierarchyCSV.sh -Dfif.propertyfile=$PWD/etc/ImportMoveCustomerWithinHierarchyCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
