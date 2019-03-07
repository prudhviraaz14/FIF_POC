@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportUpdateSimIDServiceCSV application
REM
REM $Author:   lejam  $
REM $Revision:   1.1  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/RunImportUpdateSimIDServiceCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:10   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Aug 28 2009 17:21:24   banania
# Initial revision.
# 
#    Rev 1.0   Aug 28 2009 16:19:24   banania
# Initial revision.
# 
#
# 
REM   
REM  
REM ---------------------------------------------------------------------------
# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importUpdateSimIDServiceCSV.sh -Dfif.propertyfile=$PWD/etc/ImportUpdateSimIDService.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
