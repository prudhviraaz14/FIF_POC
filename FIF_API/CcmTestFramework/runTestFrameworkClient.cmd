@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the TestFramework client
REM
REM $Author:   schwarje  $
REM $Revision:   1.8  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/CcmTestFramework/runTestFrameworkClient.cmd-arc  $
REM   
REM      Rev 1.8   Nov 15 2010 11:11:44   schwarje
REM   IT-27144: split TrxBuilder over seperate jar files to limit build dependencies
REM   
REM      Rev 1.7   Aug 17 2010 17:26:44   schwarje
REM   added KBA jars
REM   
REM      Rev 1.6   Jun 01 2010 18:26:06   schwarje
REM   IT-26029: updates
REM   
REM      Rev 1.5   Feb 10 2010 18:57:02   schwarje
REM   added XSDs
REM   
REM      Rev 1.4   Oct 15 2009 13:05:26   schwarje
REM   changed library paths
REM   
REM      Rev 1.3   Sep 16 2009 13:12:14   schwarje
REM   use new jar files for COM
REM   
REM      Rev 1.2   Aug 06 2009 12:15:22   schwarje
REM   new jar files
REM   
REM      Rev 1.1   Jul 30 2007 15:29:30   schwarje
REM   IT-19536: added new library to classpath
REM   
REM      Rev 1.0   Sep 08 2005 12:59:12   banania
REM   Initial revision.
REM  
REM 
REM ---------------------------------------------------------------------------

setlocal

REM Set the Java JDK Runtime Classes
set CP=.;%JAVA_HOME%\lib\classes.zip

REM Add the FIF API package
set CP=%CP%;%FIF_HOME%\jar\net.arcor.fif.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_AllScenariosWF1.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_Cancellation.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_DeactivateCustomer.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_ExternalOrders.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_IPCentrex.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_LTE.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_Masterdata.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_OPLineChangesWF11.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_OPLineChangesWF11CPCOM1b.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_OPTakeoverScenariosWF5.jar
set CP=%CP%;%FIF_HOME%\jar\SOMToFIFRepository_OPTerminationsWF5.jar

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
set CP=%CP%;%FIF_HOME%\lib\jdom.jar
set CP=%CP%;%FIF_HOME%\lib\de.arcor.kba.om.datatransformer.server_1.36.01.jar

%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\TestFramework.properties -cp %CP% net.arcor.fif.client.SynchronousTestFrameworkClient %*
endlocal
