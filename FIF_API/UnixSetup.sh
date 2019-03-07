#!/usr/bin/sh
# ---------------------------------------------------------------------------
# Shell script for setting up the FIF-API delivery for a UNIX environment
#
# Author: Olivier Goethals
# Date: 2003-04-10
# ---------------------------------------------------------------------------

echo "Converting files for UNIX environment..."

# Change the access rights on the files
echo "Setting all files writeable for user..."
find . -exec chmod u+w {} \;

# Convert the XML, XSLT, DTDs, properties, and sh files to UNIX file format
echo "Converting XML files to UNIX format..."
find . -name '*.xml' | xargs ./dos2unix.sh
echo "Converting XSL files to UNIX format..."
find . -name '*.xsl' | xargs ./dos2unix.sh
echo "Converting DTD files to UNIX format..."
find . -name '*.dtd' | xargs ./dos2unix.sh
echo "Converting properties files to UNIX format..."
find . -name '*.properties' | xargs ./dos2unix.sh
echo "Converting sh files to UNIX format..."
find . -name '*.sh' | xargs ./dos2unix.sh

# Change the access rights for the scripts
echo "Setting execution rights on all scripts for user and group..."
find . -name '*.sh' -exec chmod ug+x {} \;

echo "Done."
