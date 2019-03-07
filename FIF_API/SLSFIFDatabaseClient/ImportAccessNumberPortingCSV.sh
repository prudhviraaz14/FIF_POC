@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportVodafoneAccessNumberPortingCSV application
REM
REM $Author:   lejam  $
REM $Revision:   1.1  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportAccessNumberPortingCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:04   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Sep 02 2008 16:25:12   banania
# Initial revision.
# 
REM   
REM  
REM ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importAccessNumberPortingCSV.sh -Dfif.propertyfile=$PWD/etc/ImportAccessNumberPortingCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
