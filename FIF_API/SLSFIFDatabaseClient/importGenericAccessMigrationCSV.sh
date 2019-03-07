#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the ImportMigrateBitstreamAnnexJCSV application
#
# $Author:   schwarje  $
# $Revision:   1.0  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/SLSFIFDatabaseClient/importGenericAccessMigrationCSV.sh-arc  $
# 
#    Rev 1.0   Jul 22 2016 08:38:30   schwarje
# Initial revision.
# 
# ---------------------------------------------------------------------------

# Set basic FIF env settings
. $PWD/runFIFEnvSettings.sh

$JAVA_HOME/bin/java -Dfif.appname=importGenericAccessMigrationCSV.sh -Dfif.propertyfile=$PWD/etc/ImportGenericAccessMigrationCSV.properties -cp $CPATH net.arcor.fif.apps.ImportSOMOrdersToDB $@
