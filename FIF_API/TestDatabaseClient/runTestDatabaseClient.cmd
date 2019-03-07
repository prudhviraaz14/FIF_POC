@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the Test database client
REM
REM $Author:   goethalo  $
REM $Revision:   1.2  $
REM
REM History:
REM $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/TestDatabaseClient/runTestDatabaseClient.cmd-arc  $
REM  
REM     Rev 1.2   Mar 03 2004 16:27:52   goethalo
REM  Added PVCS header.
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
set CP=%CP%;%FIF_HOME%\lib\classes12.zip
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
set CP=%CP%;%FIF_HOME%\lib\commons-dbcp.jar
set CP=%CP%;%FIF_HOME%\lib\commons-pool.jar
set CP=%CP%;%FIF_HOME%\lib\commons-collections.jar

%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\TestDatabaseClient.properties -cp %CP% net.arcor.fif.client.DatabaseClient %*
endlocal
