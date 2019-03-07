@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportChangeBillingAddressCSV application
REM
REM $Author:   lejam  $
REM $Revision:   1.1  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/RunImportChangeBillingAddressCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:10   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Nov 18 2009 17:18:40   banania
# Initial revision.
# 
#
# 
REM   
REM  
REM ---------------------------------------------------------------------------
# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importChangeBillingAddressCSV.sh -Dfif.propertyfile=$PWD/etc/ImportChangeBillingAddress.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
