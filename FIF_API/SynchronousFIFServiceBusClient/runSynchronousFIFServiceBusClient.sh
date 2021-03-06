#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the OPM-FIF database client
#
# $Author:   wlazlow  $
# $Revision:   1.8  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SynchronousFIFServiceBusClient/runSynchronousFIFServiceBusClient.sh-arc  $
# 
#    Rev 1.8   Jul 11 2012 18:22:52   wlazlow
# SPN-FIF-000121451, a new spring version added
# 
#    Rev 1.7   Jun 13 2012 19:36:04   wlazlow
# ITk-31953, mcf2 update
# 
#    Rev 1.6   Apr 16 2012 14:14:18   wlazlow
# SPN-CCB-000120014, A new version of som  and mcf2 updated
# 
#    Rev 1.5   Oct 12 2011 11:02:42   wlazlow
# IT-28900, porting of a new vesrsion of MCF
# 
#    Rev 1.4   Jun 21 2011 18:41:32   wlazlow
# The newest version of MCF in CCM & FIF ported.
# 
#    Rev 1.3   Mar 31 2011 13:14:26   lejam
# Upgraded to mcf2-1.38 and spring jars 3.0.3 SPN-CCB-110949
# 
#    Rev 1.2   Nov 30 2010 11:44:58   makuier
# jsr250-api-1.0.jar added to classpath
# 
#    Rev 1.1   Nov 25 2010 11:24:10   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Jan 30 2008 19:26:40   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set FIF env settings
. $PWD/runFIFEnvSettings.sh

# Set FIF client specific env settings
CPATH=$CPATH:$FIF_HOME/xsd

CPATH=$CPATH:$FIF_HOME/lib/sjsxp.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-logging-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/jsr173_1.0_api.jar
CPATH=$CPATH:$FIF_HOME/lib/jsr250-api-1.0.jar

CPATH=$CPATH:$FIF_HOME/lib/activation-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/aspectjweaver-1.6.8.jar
CPATH=$CPATH:$FIF_HOME/lib/cglib-nodep-2.2.jar
CPATH=$CPATH:$FIF_HOME/lib/com.springsource.org.aopalliance-1.0.0.jar
CPATH=$CPATH:$FIF_HOME/lib/epsm_mcf-001.jar
CPATH=$CPATH:$FIF_HOME/lib/geronimo-jaxws_2.1_spec-1.0.jar
CPATH=$CPATH:$FIF_HOME/lib/geronimo-ws-metadata_2.0_spec-1.1.2.jar
CPATH=$CPATH:$FIF_HOME/lib/jaxb-api-2.1.jar
CPATH=$CPATH:$FIF_HOME/lib/jaxb-impl-2.1.4.jar
CPATH=$CPATH:$FIF_HOME/lib/jaxb-xjc.jar
CPATH=$CPATH:$FIF_HOME/lib/mcf2-1.43.2149.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.aop-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.asm-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.beans-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.context-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.core-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.expression-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.jdbc-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.jms-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.transaction-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.web-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.oxm-3.1.1.RELEASE.jar 
CPATH=$CPATH:$FIF_HOME/lib/saaj-api-1.3.jar
CPATH=$CPATH:$FIF_HOME/lib/saaj-impl-1.3.2.jar
CPATH=$CPATH:$FIF_HOME/lib/soap_mcf-001.jar
CPATH=$CPATH:$FIF_HOME/lib/spring-ws-2.0.4.RELEASE.jar 
CPATH=$CPATH:$FIF_HOME/lib/wsdl4j-1.6.1.jar


$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/SynchronousFIFServiceBusClient.properties -cp $CPATH net.arcor.fif.client.SynchronousServiceBusClient
