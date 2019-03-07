#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the TestFramework client
#
# $Author:   lejam  $
# $Revision:   1.5  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/CcmTestFramework/runRequestHandler.sh-arc  $
# 
#    Rev 1.5   Jul 16 2012 19:17:10   lejam
# mcf migration file names update
# 
#    Rev 1.4   Feb 07 2011 12:42:22   lejam
# Corrected classpath.
# 
#    Rev 1.3   Nov 30 2010 09:31:00   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.2   Nov 15 2010 11:11:44   schwarje
# IT-27144: split TrxBuilder over seperate jar files to limit build dependencies
# 
#    Rev 1.1   Aug 17 2010 17:26:44   schwarje
# added KBA jars
# 
#    Rev 1.0   Jun 09 2010 16:10:34   schwarje
# Initial revision.
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

# Set FIF client specific env settings
CPATH=$CPATH:$FIF_HOME/xsd

CPATH=$CPATH:$FIF_HOME/lib/sjsxp.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-logging-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/jsr173_1.0_api.jar

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
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.oxm-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.context-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.core-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.expression-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.jdbc-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.jms-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.transaction-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/org.springframework.web-3.1.1.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/saaj-api-1.3.jar
CPATH=$CPATH:$FIF_HOME/lib/saaj-impl-1.3.2.jar
CPATH=$CPATH:$FIF_HOME/lib/soap_mcf-001.jar
CPATH=$CPATH:$FIF_HOME/lib/spring-ws-2.0.4.RELEASE.jar
CPATH=$CPATH:$FIF_HOME/lib/wsdl4j-1.6.1.jar

CPATH=$CPATH:$FIF_HOME/lib/jdom.jar
CPATH=$CPATH:$FIF_HOME/lib/de.arcor.kba.om.datatransformer.server_1.36.01.jar


$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/RequestHandler.properties -cp $CPATH net.arcor.fif.client.SynchronousTestFrameworkClient $@
