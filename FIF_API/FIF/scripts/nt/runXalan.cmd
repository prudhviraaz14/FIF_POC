@echo off

setlocal

REM Set the Java JDK Runtime Classes
set CP=.;%JAVA_HOME%\lib\classes.zip

REM Add 3rd party libraries
set CP=%CP%;%FIF_HOME%\lib\xmlParserAPIs.jar
set CP=%CP%;%FIF_HOME%\lib\xercesImpl.jar
set CP=%CP%;%FIF_HOME%\lib\xml-apis.jar
set CP=%CP%;%FIF_HOME%\lib\xalan.jar

%JAVA_HOME%\bin\java -cp %CP% org.apache.xalan.xslt.Process %*
endlocal
