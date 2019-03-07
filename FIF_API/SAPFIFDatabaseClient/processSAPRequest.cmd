@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportCSVToDB application
REM
REM $Author:   goethalo  $
REM $Revision:   1.4  $
REM
REM $Author:   goethalo  $
REM $Revision:   1.4  $
REM
REM History:
REM $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/SAPFIFDatabaseClient/processSAPRequest.cmd-arc  $
REM  
REM     Rev 1.4   Aug 02 2004 15:29:46   goethalo
REM  SPN-FIF-000024410: Oracle 9i migration.
REM  
REM     Rev 1.3   Apr 28 2004 14:05:26   goethalo
REM  IT-k-000012599: Added fif.appname system property.
REM  
REM     Rev 1.2   Mar 03 2004 16:30:58   goethalo
REM  SPN-FIF-000020483: Added PVCS header.
REM 
REM ---------------------------------------------------------------------------

setlocal

REM Set the Java JDK Runtime Classes
set CP=.;%JAVA_HOME%\lib\classes.zip

REM Add the FIF API package
set CP=%CP%;%FIF_HOME%\jar\net.arcor.fif.jar

REm Add the etc directory
set CP=%CP%;%~dp0etc

REM Add 3rd party libraries
set CP=%CP%;%FIF_HOME%\lib\log4j-1.2.7.jar
set CP=%CP%;%FIF_HOME%\lib\ojdbc14.jar
set CP=%CP%;%FIF_HOME%\lib\commons-dbcp-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\commons-pool-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\commons-collections-3.0.jar
set CP=%CP%;%FIF_HOME%\lib\standard_blowfish.jar

%JAVA_HOME%\bin\java -Dfif.appname=processSAPRequest.cmd -Dfif.propertyfile=%~dp0etc\ImportCSVToDB.properties -Dfif.clientpropertyfile=%~dp0etc\SAPFIFDatabaseClient.properties -cp %CP% net.arcor.fif.apps.ImportCSVToDB %*
endlocal
