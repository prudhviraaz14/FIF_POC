#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateAddressADS application
#
# $Author:   lalit.kumar-nayak  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportMarketingPermission.cmd-arc  $
REM   
REM      Rev 1.0   Feb 06 2018 10:22:30   lalit.kumar-nayak
REM   Initial revision.
# 
#    Rev 1.0   Feb 13 2017 08:58:14   naveen.k
# Initial revision.
# 
# Rev 1.0   Feb 08 2017 naveen
# Initial revision.
# 
# ---------------------------------------------------------------------------
# Set basic FIF env settings
setlocal

REM Set the Java JDK Runtime Classes
set CP=.;%JAVA_HOME%\lib\classes.zip

REM Add the FIF API package
set CP=%CP%;%FIF_HOME%\jar\net.arcor.fif.jar

REM Add the etc directory
set CP=%CP%;%~dp0etc

REM Add 3rd party libraries
set CP=%CP%;%FIF_HOME%\lib\log4j-1.2.7.jar
set CP=%CP%;%FIF_HOME%\lib\ojdbc14.jar
set CP=%CP%;%FIF_HOME%\lib\commons-dbcp-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\commons-pool-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\commons-collections-3.0.jar
set CP=%CP%;%FIF_HOME%\lib\jms.jar
set CP=%CP%;%FIF_HOME%\lib\standard_blowfish.jar

$JAVA_HOME/bin/java -Dfif.appname=ImportMarketingPermission.cmd -Dfif.propertyfile=$PWD/etc/ImportMarketingPermissionCSV.properties -Dfif.clientpropertyfile=$PWD/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
