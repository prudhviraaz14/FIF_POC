#!/bin/sh
#
# Shell script for restarting all ISIS migration related processes in read-only mode
#
# @author goethalo
# @date 2004-03-15
#

echo "==> Restarting ISIS migration processes in read-only mode...\n"

./killMigration.sh
./startMigration_RO.sh

echo "\n==> Restarted ISIS migration processes in read-only mode.\n"

