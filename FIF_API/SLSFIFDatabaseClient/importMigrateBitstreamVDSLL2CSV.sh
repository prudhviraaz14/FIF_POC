#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateBitstreamAnnexJCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importMigrateBitstreamVDSLL2CSV.sh-arc  $
# 
#    Rev 1.0   Dec 21 2015 11:14:02   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettings.sh

$JAVA_HOME/bin/java -Dfif.appname=importMigrateBitstreamVDSLL2CSV.sh -Dfif.propertyfile=$PWD/etc/ImportMigrateBitstreamVDSLL2CSV.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
