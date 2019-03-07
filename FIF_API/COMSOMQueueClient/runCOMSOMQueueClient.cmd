@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the KBA-FIF queue client
REM
REM $Author:   schwarje  $
REM $Revision:   1.2  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/COMSOMQueueClient/runCOMSOMQueueClient.cmd-arc  $
REM   
REM      Rev 1.2   Nov 15 2010 11:11:10   schwarje
REM   IT-27144: split TrxBuilder over seperate jar files to limit build dependencies
REM   
REM      Rev 1.1   Jul 07 2010 17:04:54   schwarje
REM   CPCOM Phase 2: changed transformer jar
REM   
REM      Rev 1.0   Jun 18 2010 17:21:14   schwarje
REM   Initial revision.
REM   
REM      Rev 1.1   Mar 11 2010 13:26:36   schwarje
REM   IT-26029
REM   
REM      Rev 1.0   Oct 02 2008 13:43:54   makuier
REM   Initial revision.
REM  
REM     Rev 1.5   Jul 30 2007 15:31:00   schwarje
REM  IT-19536: added new library to classpath
REM  
REM     Rev 1.4   Aug 02 2004 15:29:36   goethalo
REM  SPN-FIF-000024410: Oracle 9i migration.
REM  
REM     Rev 1.3   Mar 03 2004 16:30:22   goethalo
REM  SPN-FIF-000020483: Added PVCS header.
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

REM Add 3rd party libraries
set CP=%CP%;%FIF_HOME%\lib\log4j-1.2.7.jar
set CP=%CP%;%FIF_HOME%\lib\ojdbc14.jar
set CP=%CP%;%FIF_HOME%\lib\commons-dbcp-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\commons-pool-1.1.jar
set CP=%CP%;%FIF_HOME%\lib\commons-collections-3.0.jar
set CP=%CP%;%FIF_HOME%\lib\xmlParserAPIs.jar
set CP=%CP%;%FIF_HOME%\lib\xercesImpl.jar
rem set CP=%CP%;%FIF_HOME%\lib\xml-apis.jar
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
set CP=%CP%;%FIF_HOME%\lib\jdom.jar
set CP=%CP%;%FIF_HOME%\lib\de.arcor.kba.om.datatransformer.server_1.36.01.jar


%JAVA_HOME%\bin\java -Dfif.propertyfile=%~dp0etc\COMSOMQueueClient.properties -cp %CP% net.arcor.fif.client.SynchronousSOMQueueClient %*
endlocal
