#!/bin/sh
#
# Shell script for showing all ISIS migration related processes
#
# @author goethalo
# @date 2004-03-15
#

# MQ reader process

ps -xf -u ccb20bis | grep 'java CcmMQReader' | grep -v 'grep'

# FIF Interface processes

ps -xf -u ccb20bis | grep 'CcmFifInterface32is isis' | grep -v 'grep'

# CBM and PSM

ps -xf -u ccb20bis | grep 'IS_' |  grep -v 'grep'

# FIF-API

ps -xf -u ccb20bis | grep 'java' | grep 'ISISMigrationDatabaseClient' |  grep -v 'grep'
