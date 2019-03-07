@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the FIF service bus client
REM
REM $Author:   schwarje  $
REM $Revision:   1.0  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/SynchronousFIFServiceBusClient/runSynchronousFIFServiceBusClient.cmd-arc  $
REM   
REM      Rev 1.0   Jan 30 2008 19:26:40   schwarje
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
set CP=%CP%;%FIF_HOME%\xsd

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
set CP=%CP%;%FIF_HOME%\lib\connector.jar
set CP=%CP%;%FIF_HOME%\lib\sjsxp.jar
set CP=%CP%;%FIF_HOME%\lib\spring.jar
set CP=%CP%;%FIF_HOME%\lib\mcf.jar
set CP=%CP%;%FIF_HOME%\lib\mcf-sbus.jar
set CP=%CP%;%FIF_HOME%\lib\commons-logging-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\jaxb-api.jar
set CP=%CP%;%FIF_HOME%\lib\jaxb-impl.jar
set CP=%CP%;%FIF_HOME%\lib\jsr173_1.0_api.jar
set CP=%CP%;%FIF_HOME%\lib\standard_blowfish.jar

REM ***************** add more libraries!!!! **************

%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\SynchronousFIFServiceBusClient.properties -cp %CP% net.arcor.fif.client.SynchronousServiceBusClient %*
endlocal
