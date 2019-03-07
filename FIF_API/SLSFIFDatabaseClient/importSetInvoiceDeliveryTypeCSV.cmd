@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the ImportSetInvoiceDeliveryTypeCSV application
REM
REM $Author:   schwarje  $
REM $Revision:   1.0  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importSetInvoiceDeliveryTypeCSV.cmd-arc  $
REM   
REM      Rev 1.0   Apr 01 2008 12:41:58   schwarje
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

%JAVA_HOME%\bin\java -Dfif.appname=importSetInvoiceDeliveryTypeCSV.cmd -Dfif.propertyfile=%~dp0etc\ImportSetInvoiceDeliveryTypeCSV.properties -Dfif.clientpropertyfile=%~dp0etc\SLSFIFDatabaseClient.properties -cp %CP% net.arcor.fif.apps.ImportCSVToDB %*
endlocal
