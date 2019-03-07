@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportMoveCustomerWithinHierarchy application
REM
REM $Author:   IARIZOVA  $
REM $Revision:   1.3  $
REM
REM History:
REM $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/SLSFIFDatabaseClient/importMoveCustomerWithinHierarchyCSV.cmd-arc  $
REM   
REM      Rev 1.3   Sep 16 2004 13:50:50   IARIZOVA
REM   changed properties file name
REM   
REM      Rev 1.2   Sep 16 2004 12:33:30   IARIZOVA
REM   changed properties file name
REM   
REM      Rev 1.1   Aug 02 2004 15:29:58   goethalo
REM   SPN-FIF-000024410: Oracle 9i migration.
REM   
REM      Rev 1.0   Jul 21 2004 17:22:28   IARIZOVA
REM   Initial revision.
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

%JAVA_HOME%\bin\java -Dfif.appname=importMoveCustomerWithinHierarchyCSV.cmd -Dfif.propertyfile=%~dp0etc\ImportMoveCustomerWithinHierarchyCSV.properties -Dfif.clientpropertyfile=%~dp0etc\SLSFIFDatabaseClient.properties -cp %CP% net.arcor.fif.apps.ImportCSVToDB %*

endlocal
