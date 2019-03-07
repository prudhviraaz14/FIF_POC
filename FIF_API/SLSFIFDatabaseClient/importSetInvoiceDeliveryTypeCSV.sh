#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportSetInvoiceDeliveryTypeCSV application
#
# $Author:   lejam  $
# $Revision:   1.1  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importSetInvoiceDeliveryTypeCSV.sh-arc  $
# 
#    Rev 1.1   Nov 25 2010 11:24:08   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.0   Apr 01 2008 12:41:58   schwarje
# Initial revision.
# 
#    Rev 1.0   Mar 20 2008 15:42:52   schwarje
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importSetInvoiceDeliveryTypeCSV.sh -Dfif.propertyfile=$PWD/etc/ImportSetInvoiceDeliveryTypeCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
