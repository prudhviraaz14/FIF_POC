@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the OPM-FIF database client
REM
REM $Author:   schwarje  $
REM $Revision:   1.6  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/OPMFIFDatabaseClient/runOPMFIFDatabaseClient.cmd-arc  $
REM  
REM     Rev 1.6   Jun 01 2010 18:27:46   schwarje
REM  IT-26029: updates
REM  
REM     Rev 1.5   Jul 30 2007 15:31:34   schwarje
REM  IT-19536: added new library to classpath
REM  
REM     Rev 1.4   Aug 02 2004 15:29:44   goethalo
REM  SPN-FIF-000024410: Oracle 9i migration.
REM  
REM     Rev 1.3   Mar 03 2004 16:30:48   goethalo
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
set CP=%CP%;%FIF_HOME%\lib\xmlParserAPIs.jar
set CP=%CP%;%FIF_HOME%\lib\xercesImpl.jar
set CP=%CP%;%FIF_HOME%\lib\xml-apis.jar
set CP=%CP%;%FIF_HOME%\lib\xalan.jar
set CP=%CP%;%FIF_HOME%\lib\oraclexsql.jar
set CP=%CP%;%FIF_HOME%\lib\xsu12.jar
set CP=%CP%;%FIF_HOME%\lib\xmlparserv2.jar
set CP=%CP%;%FIF_HOME%\lib\junit.jar
set CP=%CP%;%FIF_HOME%\lib\com.ibm.mq.jar
set CP=%CP%;%FIF_HOME%\lib\com.ibm.mqjms.jar
set CP=%CP%;%FIF_HOME%\lib\jms.jar
set CP=%CP%;%FIF_HOME%\lib\standard_blowfish.jar
set CP=%CP%;%FIF_HOME%\lib\connector.jar

%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\OPMFIFDatabaseClient.properties -cp %CP% net.arcor.fif.client.SynchronousDatabaseClient %*
endlocal
