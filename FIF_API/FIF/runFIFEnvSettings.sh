#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for FIF environment setting
#
# $Author:   lejam  $
# $Revision:   1.3  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/FIF/runFIFEnvSettings.sh-arc  $
# 
#    Rev 1.3   Nov 22 2017 13:09:12   lejam
# MQ7.5 upgrade Added MQ7.5 jars
# 
#    Rev 1.2   Nov 08 2017 14:36:12   lejam
# Added MQ7.5 jars
# 
#    Rev 1.1   Dec 02 2010 11:31:14   makuier
# Use xml-apis.jar.
# 
#    Rev 1.0   Nov 25 2010 11:09:26   lejam
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

# Set FIF env settings
CPATH=$CPATH:$FIF_HOME/lib/xml-apis.jar
CPATH=$CPATH:$FIF_HOME/lib/xercesImpl.jar
CPATH=$CPATH:$FIF_HOME/lib/xalan.jar
CPATH=$CPATH:$FIF_HOME/lib/oraclexsql.jar
CPATH=$CPATH:$FIF_HOME/lib/xsu12.jar
CPATH=$CPATH:$FIF_HOME/lib/xmlparserv2.jar
CPATH=$CPATH:$FIF_HOME/lib/junit.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mqjms.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.soap.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.jms.Nojndi.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.jmqi.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.headers.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.defaultconfig.jar
CPATH=$CPATH:$FIF_HOME/lib/com.ibm.mq.commonservices.jar
CPATH=$CPATH:$FIF_HOME/lib/dhbcore.jar
CPATH=$CPATH:$FIF_HOME/lib/connector.jar
CPATH=$CPATH:$FIF_HOME/lib/jta.jar
