#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportCreateAdjustmentCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importCreateContractCSV.sh-arc  $
# 
#    Rev 1.0   Aug 20 2014 17:10:50   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importCreateContractCSV.sh -Dfif.propertyfile=$PWD/etc/ImportCreateContractCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
