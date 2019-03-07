#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportSLTAddHardwareServiceCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importSLTAddHardwareServiceCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:08   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Sep 06 2006 18:33:16   wlazlow
# Initial revision.
# 
#  
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importSLTAddHardwareServiceCSV.sh -Dfif.propertyfile=$PWD/etc/ImportSLTAddHardwareServiceCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
