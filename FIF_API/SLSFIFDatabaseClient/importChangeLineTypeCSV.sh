#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportChangeLineTypeCSV application
#
# $Author:   lejam  $
# $Revision:   1.2  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importChangeLineTypeCSV.sh-arc  $
# 
#    Rev 1.2   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.1   Aug 23 2004 15:38:06   goethalo
# IT-11106 - ISIS provisioning: Added missing import scripts (9i version).
# 
#    Rev 1.0   Aug 23 2004 15:34:56   goethalo
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh


$JAVA_HOME/bin/java -Dfif.appname=importChangeLineTypeCSV.sh -Dfif.propertyfile=$PWD/etc/ImportChangeLineTypeCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
