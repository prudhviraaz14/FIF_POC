#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the KBA-FIF queue client
#
# $Author:   lejam  $
# $Revision:   1.5  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/COMSOMQueueClient/runCOMSOMQueueClient.sh-arc  $
# 
#    Rev 1.5   Sep 30 2011 15:02:16   lejam
# Added SOMToFIFRepository_Activation IT-28575
# 
#    Rev 1.4   Nov 29 2010 16:19:52   lejam
# Added SOMToFIFRepository_LineChangeHW.jar
# 
#    Rev 1.3   Nov 29 2010 16:14:14   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.2   Nov 15 2010 11:11:10   schwarje
# IT-27144: split TrxBuilder over seperate jar files to limit build dependencies
# 
#    Rev 1.1   Jul 07 2010 17:04:54   schwarje
# CPCOM Phase 2: changed transformer jar
# 
#    Rev 1.0   Jun 18 2010 17:21:14   schwarje
# Initial revision.
# 
#    Rev 1.1   Mar 11 2010 13:26:36   schwarje
# IT-26029
# 
#    Rev 1.0   Oct 02 2008 13:43:54   makuier
# Initial revision.
# 
#    Rev 1.4   Jul 30 2007 15:31:00   schwarje
# IT-19536: added new library to classpath
# 
#    Rev 1.3   Aug 02 2004 15:29:36   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.2   Mar 02 2004 11:19:16   goethalo
# SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
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
CPATH=$CPATH:$FIF_HOME/lib/jdom.jar
CPATH=$CPATH:$FIF_HOME/lib/de.arcor.kba.om.datatransformer.server_1.36.01.jar

$JAVA_HOME/bin/java -Dfif.propertyfile=$PWD/etc/COMSOMQueueClient.properties -cp $CPATH net.arcor.fif.client.SynchronousSOMQueueClient
