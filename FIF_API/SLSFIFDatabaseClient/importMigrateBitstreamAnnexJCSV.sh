#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateBitstreamAnnexJCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importMigrateBitstreamAnnexJCSV.sh-arc  $
# 
#    Rev 1.0   Oct 19 2015 13:53:30   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettings.sh

$JAVA_HOME/bin/java -Dfif.appname=importMigrateBitstreamAnnexJCSV.sh -Dfif.propertyfile=$PWD/etc/ImportMigrateBitstreamAnnexJCSV.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
