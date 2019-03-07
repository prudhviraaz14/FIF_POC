@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportChangeTariffCSV application
REM
REM $Author:   goethalo  $
REM $Revision:   1.4  $
REM
REM History:
REM $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/SLSFIFDatabaseClient/importChangeTariffCSV.cmd-arc  $
REM  
REM     Rev 1.4   Aug 02 2004 15:29:54   goethalo
REM  SPN-FIF-000024410: Oracle 9i migration.
REM  
REM     Rev 1.3   Apr 28 2004 14:09:54   goethalo
REM  IT-k-000012599: Add fif.appname system property.
REM  
REM     Rev 1.2   Mar 03 2004 16:31:06   goethalo
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
set CP=%CP%;%FIF_HOME%\lib\jms.jar
set CP=%CP%;%FIF_HOME%\lib\standard_blowfish.jar

%JAVA_HOME%\bin\java -Dfif.appname=importChangeTariffCSV.cmd -Dfif.propertyfile=%~dp0etc\ImportChangeTariffCSV.properties -Dfif.clientpropertyfile=%~dp0etc\SLSFIFDatabaseClient.properties -cp %CP% net.arcor.fif.apps.ImportCSVToDB %*
endlocal
