#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateMobilePhoneContractCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importCreateMobilePhoneContractCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Jan 20 2007 16:06:06   schwarje
# Initial revision.
# 
#    Rev 1.0   May 19 2005 16:23:00   schwarje
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importCreateMobilePhoneContractCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCreateMobilePhoneContractCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
