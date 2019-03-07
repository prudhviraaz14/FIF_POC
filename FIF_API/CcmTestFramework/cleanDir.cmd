@echo off
REM ---------------------------------------------------------------------------
REM NT script cleaning up the sent, reply & invalid-reply directory
REM $Author:   banania  $
REM $Revision:   1.0  $
REM
REM History:
REM $Log:   //PVCS_FIF/archives/FIF_API/CcmTestFramework/cleanDir.cmd-arc  $
REM   
REM      Rev 1.0   Oct 28 2005 14:52:10   banania
REM   Initial revision.
REM   
REM      Rev 1.0   Sep 08 2005 12:59:12   banania
REM   Initial revision.
REM  
REM 
REM ---------------------------------------------------------------------------

cd sent
del /f/q *.*
cd..
cd reply
del /f/q *.*
cd..
cd invalid-reply
del /f/q *.*
cd..
