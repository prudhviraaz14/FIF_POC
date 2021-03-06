@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the IVR-FIF database client
REM
REM $Author:   schwarje  $
REM $Revision:   1.2  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/IVRFIFDatabaseClient/runIVRFIFDatabaseClient.cmd-arc  $
REM   
REM      Rev 1.2   Jun 01 2010 18:27:22   schwarje
REM   IT-26029: updates
REM   
REM      Rev 1.1   Jul 30 2007 15:30:18   schwarje
REM   IT-19536: added new library to classpath
REM   
REM      Rev 1.0   Apr 23 2007 14:36:38   schwarje
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
set CP=%CP%;%FIF_HOME%\lib\connector.jar

%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\IVRFIFDatabaseClient.properties -cp %CP% net.arcor.fif.client.SynchronousDatabaseClient %*
endlocal
