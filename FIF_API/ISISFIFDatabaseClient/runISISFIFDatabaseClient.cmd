@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the SLS-FIF database client
REM
REM $Author:   goethalo  $
REM $Revision:   1.1  $
REM
REM History:
REM $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/ISISFIFDatabaseClient/runISISFIFDatabaseClient.cmd-arc  $
REM   
REM      Rev 1.1   Aug 02 2004 15:29:32   goethalo
REM   SPN-FIF-000024410: Oracle 9i migration.
REM   
REM      Rev 1.0   May 28 2004 12:16:46   goethalo
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

%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\ISISFIFDatabaseClient.properties -cp %CP% net.arcor.fif.client.DatabaseClient %*
endlocal
