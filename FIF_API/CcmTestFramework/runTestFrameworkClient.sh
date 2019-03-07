#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the TestFramework client
#
# $Author:   lejam  $
# $Revision:   1.16  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/CcmTestFramework/runTestFrameworkClient.sh-arc  $
# 
#    Rev 1.16   Sep 12 2012 16:01:40   lejam
# Added sbus-epsm.jar
# 
#    Rev 1.15   Sep 06 2012 16:53:50   lejam
# Added jsr jar
# 
#    Rev 1.14   Aug 30 2012 16:00:18   lejam
# updated commons-logging jar name
# 
#    Rev 1.13   Sep 30 2011 16:06:28   lejam
# Added SOMToFIFRepository_Activation IT-28575
# 
#    Rev 1.12   Aug 08 2011 13:58:04   schwarje
# BKS for TF
# 
#    Rev 1.11   Feb 07 2011 10:08:54   lejam
# Corrected classpath definition
# 
#    Rev 1.10   Nov 29 2010 16:19:52   lejam
# Added SOMToFIFRepository_LineChangeHW.jar
# 
#    Rev 1.9   Nov 29 2010 16:14:16   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.8   Nov 15 2010 11:11:46   schwarje
# IT-27144: split TrxBuilder over seperate jar files to limit build dependencies
# 
#    Rev 1.7   Aug 17 2010 17:26:44   schwarje
# added KBA jars
# 
#    Rev 1.6   Jun 01 2010 18:26:06   schwarje
# IT-26029: updates
# 
#    Rev 1.5   Feb 10 2010 18:57:02   schwarje
# added XSDs
# 
#    Rev 1.4   Oct 15 2009 13:05:30   schwarje
# changed library paths
# 
#    Rev 1.3   Sep 16 2009 13:12:12   schwarje
# use new jar files for COM
# 
#    Rev 1.2   Aug 06 2009 12:15:22   schwarje
# new jar files
# 
#    Rev 1.1   Jul 30 2007 15:29:30   schwarje
# IT-19536: added new library to classpath
# 
#    Rev 1.0   Sep 08 2005 12:59:12   banania
# Initial revision.
# 
# 
# 
# ---------------------------------------------------------------------------

# Set FIF env settings
. $PWD/runFIFEnvSettings.sh

# Add the FIF API package
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_AllScenariosWF1.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_Cancellation.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_DeactivateCustomer.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_ExternalOrders.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_IPCentrex.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_LTE.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_Masterdata.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_OPLineChangesWF11.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_OPLineChangesWF11CPCOM1b.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_OPTakeoverScenariosWF5.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_OPTerminationsWF5.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_LineChangeHW.jar
CPATH=$CPATH:$FIF_HOME/jar/SOMToFIFRepository_Activation.jar

# Set FIF client specific env settings

CPATH=$CPATH:$FIF_HOME/lib/sjsxp.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-logging-1.1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/jdom.jar
CPATH=$CPATH:$FIF_HOME/lib/de.arcor.kba.om.datatransformer.server_1.36.01.jar
CPATH=$CPATH:$FIF_HOME/lib/jsr173_1.0_api.jar

CPATH=$CPATH:$FIF_HOME/lib/BKS/bks.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/bksxsd.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/activation-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/aspectjweaver-1.6.8.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/cglib-nodep-2.2.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/com.springsource.org.aopalliance-1.0.0.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/epsm_mcf-001.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/geronimo-jaxws_2.1_spec-1.0.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/geronimo-ws-metadata_2.0_spec-1.1.2.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/jaxb-api-2.1.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/jaxb-impl-2.1.4.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/jaxb-xjc.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/jsr250-api-1.0.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/mcf2-1.40.1947.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/saaj-api-1.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/saaj-impl-1.3.2.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/soap_mcf-001.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.aop-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.asm-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.beans-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.context-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.core-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.expression-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.jdbc-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.jms-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.transaction-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring.web-3.0.3.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/spring-ws-1.5.9.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/wsdl4j-1.6.1.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/timeandmoney-0_5_1.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/commons-codec-1.4.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/epsm-commontypes.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/aaw-common-lib.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/aawSprache.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/ask-model.jar
CPATH=$CPATH:$FIF_HOME/lib/BKS/sbus-epsm.jar

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/TestFramework.properties -cp $CPATH net.arcor.fif.client.SynchronousTestFrameworkClient $@
