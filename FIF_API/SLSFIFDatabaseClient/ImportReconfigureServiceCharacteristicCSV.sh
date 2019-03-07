#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportReconfigureServiceCharacteristicCSV.sh application
#
# $Author:   lalit.kumar-nayak  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/ImportReconfigureServiceCharacteristicCSV.sh-arc  $
# 
#    Rev 1.0   Jul 14 2016 08:01:24   lalit.kumar-nayak
# Initial revision.
# 
#  
# 
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettingsBasic.sh


$JAVA_HOME/bin/java -Dfif.appname=ImportReconfigureServiceCharacteristicCSV.sh -Dfif.propertyfile=$PWD/etc/ImportReconfigureServiceCharacteristicCSV.properties.template -Dfif.clientpropertyfile=$PWD/etc/SLSFIFDatabaseClient.properties -cp $CPATH net.arcor.fif.apps.ImportCSVToDB $@
 
