#!/bin/bash

DEBRELS=`cat debian/changelog | head -n1 | grep -o "(.*)" | tr -d "()"`
VERS=`echo "${DEBRELS}" | cut -d '-' -f1`
RELS=`echo "${DEBRELS}" | cut -d '-' -f2`

git branch -D source
git checkout -b source
mkdir scanmem
git mv debian/ scanmem/
git commit -a -m "Move dir 'debian' into new dir 'scanmem'"
cd scanmem
uscan --force-download
git add ../*
git commit -a -m "Run 'uscan --force-download'

The quilt format always requires an orig.tar.gz file. So provide it."
tar xzf ../scanmem-${VERS}.tar.gz
mv scanmem-${VERS}/* .
mv scanmem-${VERS}/.* .
rmdir scanmem-${VERS}
git add *
git add .*
git commit -a -m "Import the code from v${VERS} upstream"
debuild -S
git add ../*
git commit -a -m "Run 'debuild -S'"
git branch -D unstable-amd64
git checkout -b unstable-amd64
cd ..
sbuild -A --arch=amd64 -c unstable-amd64-sbuild -d unstable --run-lintian -k 84927565 scanmem_${VERS}-${RELS}.dsc
git add *
git commit -a -m "Build with local sbuild for unstable-amd64

Run the following command to build this with sbuild for Debian
unstable amd64:

$ sbuild -A --arch=amd64 -c unstable-amd64-sbuild -d unstable \
--run-lintian -k 84927565 scanmem_${VERS}-${RELS}.dsc"
