#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportModifyVodafoneCustomerCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importModifyVodafoneCustomerCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:08   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   May 24 2007 10:37:20   makuier
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importModifyVodafoneCustomerCSV.sh -Dfif.propertyfile=$PWD/etc/ImportModifyVodafoneCustomerCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
