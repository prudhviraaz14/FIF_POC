#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportChangeTariffCSV application
#
# $Author:   lejam  $
# $Revision:   1.4  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importChangeTariffCSV.sh-arc  $
# 
#    Rev 1.4   Nov 25 2010 11:24:06   lejam
# Splitted env setting files and added, removed jars IT-29080
# 
#    Rev 1.3   Aug 02 2004 15:29:54   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.2   Apr 28 2004 14:09:54   goethalo
# IT-k-000012599: Add fif.appname system property.
# 
#    Rev 1.1   Mar 02 2004 11:19:38   goethalo
# SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
# 
#    Rev 1.0   Feb 04 2004 10:07:40   goethalo
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh

$JAVA_HOME/bin/java -Dfif.appname=importChangeTariffCSV.sh -Dfif.propertyfile=$PWD/etc/ImportChangeTariffCSV.properties -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
