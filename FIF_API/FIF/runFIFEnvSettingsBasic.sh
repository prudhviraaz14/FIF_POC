#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for basic FIF environment setting
#
# $Author:   lejam  $
# $Revision:   1.2  $
# 
# History:
# $Log:   //PVCS_FIF/archives/FIF_API/FIF/runFIFEnvSettingsBasic.sh-arc  $
# 
#    Rev 1.2   Sep 06 2012 16:52:30   lejam
# updated jms jar
# 
#    Rev 1.1   Nov 29 2010 15:28:10   lejam
# Moved back to commons-dbcp-1.1.jar SPN-FIF-000106980
# 
#    Rev 1.0   Nov 25 2010 11:09:26   lejam
# Initial revision.
# 
# 
# ---------------------------------------------------------------------------

# Set the Java JDK Runtime Classes
CPATH=.:$JAVA_HOME/lib/classes.zip

# Add the FIF API package
CPATH=$CPATH:$FIF_HOME/jar/net.arcor.fif.jar

# Add the etc directory
CPATH=$CPATH:$PWD/etc

# Add 3rd party libraries
CPATH=$CPATH:$FIF_HOME/lib/log4j-1.2.15.jar
CPATH=$CPATH:$FIF_HOME/lib/ojdbc14.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-dbcp-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-pool-1.3.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-collections-3.0.jar
CPATH=$CPATH:$FIF_HOME/lib/commons-codec-1.4.jar
CPATH=$CPATH:$FIF_HOME/lib/jms-1.1.jar
CPATH=$CPATH:$FIF_HOME/lib/standard_blowfish.jar
