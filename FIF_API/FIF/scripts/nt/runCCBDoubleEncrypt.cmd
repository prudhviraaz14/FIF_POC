@echo off
REM ---------------------------------------------------------------------------
REM NT script for launching the CCBDoubleEncrypt application
REM
REM $Author:   goethalo  $
REM $Revision:   1.3  $
REM
REM History:
REM $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/scripts/nt/runCCBDoubleEncrypt.cmd-arc  $
REM  
REM     Rev 1.3   Aug 02 2004 15:29:18   goethalo
REM  SPN-FIF-000024410: Oracle 9i migration.
REM  
REM     Rev 1.2   Mar 03 2004 16:29:40   goethalo
REM  SPN-FIF-000020483: Added PVCS header.
REM 
REM ---------------------------------------------------------------------------

setlocal

REM Set the Java JDK Runtime Classes
set CP=.;%JAVA_HOME%\lib\classes.zip

REM Add the FIF API package
set CP=%CP%;%FIF_HOME%\jar\net.arcor.fif.jar

REM Add 3rd party libraries
set CP=%CP%;%FIF_HOME%\lib\standard_blowfish.jar

%JAVA_HOME%\bin\java -cp %CP% net.arcor.fif.apps.CCBDoubleEncrypt %*
endlocal
