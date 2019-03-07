#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for converting files from DOS to UNIX format
#
# Author: Olivier Goethals
# Date: 2003-04-10
# ---------------------------------------------------------------------------
for file in $*
do
        dos2ux $file >$file.new
        mv $file.new $file
done
