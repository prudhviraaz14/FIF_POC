#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the FIFServiceBusResponseClient
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/ConsolidateSubscriptionDataResponseClient/runConsolidateSubscriptionDataResponseClient.sh-arc  $
# 
#    Rev 1.0   Jan 18 2013 08:23:32   schwarje
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


$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/ConsolidateSubscriptionDataResponseClient.properties -cp $CPATH net.arcor.fif.client.SynchronousServiceBusClient
