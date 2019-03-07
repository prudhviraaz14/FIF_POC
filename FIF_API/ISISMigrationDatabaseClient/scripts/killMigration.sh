#!/bin/sh
#
# Shell script for killing all ISIS migration related processes
#
# @author goethalo
# @date 2004-03-15
#

echo "--> Killing all ISIS migration processes...\n"

# Kill the MQ reader process

for X in `ps -xf -u ccb20bis | grep 'java CcmMQReader' | grep -v 'grep' | awk {'print $2'}`; do
  echo "Killing MQ Reader (PID $X)";
  kill -9 $X
done

# Kill the FIF Interface processes

for X in `ps -xf -u ccb20bis | grep 'CcmFifInterface32is isis' | grep -v 'grep' |  awk {'print $2'}`; do
  echo "Killing FIF Interface instance (PID $X)";
  kill -9 $X
done

# Kill CBM and PSM

for X in `ps -xf -u ccb20bis | grep 'IS_' |  grep -v 'grep' | awk {'print $2'}`; do
  echo "Killing Application server instance (PID $X)";
  kill -9 $X
done


# Kill FIF-API

for X in `ps -xf -u ccb20bis | grep 'java' | grep 'ISISMigrationDatabaseClient' |  grep -v 'grep' | awk {'print $2'}`; do
  echo "Killing FIF_API instance (PID $X)";
  kill -9 $X
done

echo "\n--> Killed all ISIS migration processes.\n"
