#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for launching the CCBDoubleEncrypt application
#
# $Author:   goethalo  $
# $Revision:   1.2  $
# 
# History:
# $Log:   F:/GRUPPEN/PROJEKTE/PVCS_FIF/archives/FIF/FIF/scripts/unix/runCCBDoubleEncrypt.sh-arc  $
# 
#    Rev 1.2   Aug 02 2004 15:29:20   goethalo
# SPN-FIF-000024410: Oracle 9i migration.
# 
#    Rev 1.1   Mar 02 2004 11:18:30   goethalo
# SPN-CCB-000020494: Changed way property files are read.  Now the fully qualified property file name must be provided.
# 
# ---------------------------------------------------------------------------

# Set the Java JDK Runtime Classes
CPATH=.:$JAVA_HOME/lib/classes.zip

# Add the FIF API package
CPATH=$CPATH:$FIF_HOME/jar/net.arcor.fif.jar

# Add 3rd party libraries
CPATH=$CPATH:$FIF_HOME/lib/standard_blowfish.jar

$JAVA_HOME/bin/java -cp $CPATH net.arcor.fif.apps.CCBDoubleEncrypt $@
