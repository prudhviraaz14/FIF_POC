#!/bin/sh
#
# Shell script for restarting all ISIS migration related processes
#
# @author goethalo
# @date 2004-03-15
#

echo "==> Restarting ISIS migration processes...\n"

./killMigration.sh
./startMigration.sh

echo "\n==> Restarted ISIS migration processes.\n"

